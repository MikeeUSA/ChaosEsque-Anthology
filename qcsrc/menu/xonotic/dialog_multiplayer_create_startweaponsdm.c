#ifdef INTERFACE
CLASS(XonoticStartweaponsdmDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticStartweaponsdmDialog, fill, void(entity))
	METHOD(XonoticStartweaponsdmDialog, showNotify, void(entity))
	METHOD(XonoticStartweaponsdmDialog, close, void(entity))
	ATTRIB(XonoticStartweaponsdmDialog, title, string, _("Start weapons"))
	ATTRIB(XonoticStartweaponsdmDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticStartweaponsdmDialog, intendedWidth, float, 1.0)
	ATTRIB(XonoticStartweaponsdmDialog, rows, float, 82)
	ATTRIB(XonoticStartweaponsdmDialog, columns, float, 4)
	ATTRIB(XonoticStartweaponsdmDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticStartweaponsdmDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticStartweaponsdmDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticStartweaponsdmDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Cells")));
			e.colorL = '0.5 0.75 1.0';
			me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 300, 5, "g_start_ammo_cells"));
			e.colorL = '0.5 0.75 1.0';
			e.color2 = '0.5 0.75 1.0';
			e.colorC = '0.5 0.75 1.0';
			e.colorF = '0.5 0.75 1.0';
			e.colorD = '0.5 0.75 1.0';
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Nails")));
			e.colorL = '0.5 0.5 0.5';
			me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 300, 5, "g_start_ammo_nails"));
			e.colorL = '0.5 0.5 0.5';
			e.color2 = '0.5 0.5 0.5';
			e.colorC = '0.5 0.5 0.5';
			e.colorF = '0.5 0.5 0.5';
			e.colorD = '0.5 0.5 0.5';
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Rockets")));
			e.colorL = '1.0 0.5 0.5';
			me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 300, 5, "g_start_ammo_rockets"));
			e.colorL = '1.0 0.5 0.5';
			e.color2 = '1.0 0.5 0.5';
			e.colorC = '1.0 0.5 0.5';
			e.colorF = '1.0 0.5 0.5';
			e.colorD = '1.0 0.5 0.5';
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Shells")));
			e.colorL = '0.75 0.75 0.5';
			me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 300, 5, "g_start_ammo_shells"));
			e.colorL = '0.75 0.75 0.5';
			e.color2 = '0.75 0.75 0.5';
			e.colorC = '0.75 0.75 0.5';
			e.colorF = '0.75 0.75 0.5';
			e.colorD = '0.75 0.75 0.5';
			
	me.TR(me);
	me.TD(me, 1, 0.5, makeXonoticTextLabel(0, _("Total Override")));
		me.TD(me, 1, 1.8, makeXonoticSlider(0, 2, 1, "g_start_weapon_teamoverrides"));
		//was 1.9, added the 0.06, changed to 1.8, same for the
		//multitool-utilitool attributes with the 2.3
	///////////////////////////////////
	//Old code for multitool-utilitool options:
	//me.TD(me, 1, 0.34, e = makeXonoticCheckBox(0, "g_balance_multitool_nocost", _("Zero Build Cost")));
	//me.TD(me, 1, 0.34, e = makeXonoticCheckBox(0, "g_balance_multitool_nobuildtime", _("Zero Build Time")));
	//me.TD(me, 1, 0.34, e = makeXonoticCheckBox(0, "g_balance_multitool_noknowledgeneeded", _("Zero Knowledge")));
	//me.TD(me, 1, 0.33, e = makeXonoticCheckBox(0, "g_balance_multitool_ancientonly", _("MT: Ancient")));
	//me.TD(me, 1, 0.06, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noweapons", _("")));
	//me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_nosuits", _("")));
	//me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noaircraft", _("No Air")));
	//
	//me.TR(me);
	//me.TDempty(me, 2.3);
	//me.TD(me, 1, 0.325, e = makeXonoticTextLabel(0, _("FreeBuild Blocks")));
	//me.TD(me, 1, 0.175, e = makeXonoticSlider(0, 4, 1, "g_balance_multitool_freebuild_blocks"));
	//me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_multitool_toofarblockscountasbuildings", _("")));
	//me.TD(me, 1, 0.325, e = makeXonoticTextLabel(0, _("FreeBuild All")));
	//me.TD(me, 1, 0.175, e = makeXonoticSlider(0, 4, 1, "g_balance_multitool_freebuild"));
	//me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_ignorebuild_blocks", _("")));
	//me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_claimstones", _("")));
	//me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_bedspawnpoints", _("")));
	//me.TD(me, 1, 0.06, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noammo", _("")));
	//me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_nomiscgroundvehicle", _("")));
	//me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_notanks", _("No Tanks")));
	///////////////////////////////////	


//Team1
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("General:")));
	
	me.TD(me, 1, 0.4, e = makeXonoticCheckBox(0, "g_nades", _("Grenades")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_grenades"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Fragnades")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_fragnades"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Flashbangs")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_flashbangs"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Smokenades")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_smokenades"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Landmines")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_landmines"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("AT Mines")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_atmines"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_laser", _(" Laser")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shotgun", _(" Shotgun")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_crypistol", _(" Crypistol")));
		e.colorL = '0.9 0.7 1.0'; e.cvarOffValue = "-1";
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_uzi", _(" MachineGun")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_grenadelauncher", _(" Mortar")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_sportshotgun", _(" SportShotgun")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_minelayer", _(" Minelayer")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_electro", _(" Electro")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_spikedflail", _(" SpikedFlail")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
		
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_crylink", _(" Crylink")));
		e.colorL = '0.9 0.7 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_nex", _(" Nex")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shootingstar", _(" Shooting-Star")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
		
	
			
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_hagar", _(" Hagar")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_rocketlauncher", _(" RocketLauncher")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_fightersword", _(" FighterSword")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_porto", _(" Port-O-Launch")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_minstanex", _(" MinstaNex")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_styeraug", _(" Styer Aug")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_hook", _(" Hook")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_hlac", _(" HLAC")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m9pistol", _(" M9 Pistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	
	
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_tuba", _(" Tuba")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_rifle", _(" Rifle")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_styertmp", _(" Styer TMP")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_fireball", _(" Fireball")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_seeker", _(" Seeker")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_crylancer", _(" Crylancer")));
		e.colorL = '0.9 0.7 1.0'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pistol", _(" Pistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_hmg", _(" HeavyMachineGun")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m82rifle", _(" M82 Rifle")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_mg", _(" AssaultRifle")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_explosivevest", _(" Explosives")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_amr18", _(" AMR-18")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1"; //1984, california, are you a friend of sa... .....
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_crossbowdtwr", _(" Crossbow")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_warhammerspiked", _(" Warhammer")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_spas12", _(" SPAS-12")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1"; //12 Gauge Autoloader
	
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shotgunautomat", _(" ShotgunAutomat")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pumpshotgun", _(" PumpShotgun")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_longpistol", _(" .45 Longslide")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightninggun", _(" Lightninggun")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_g98", _(" G98")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m1903", _(" M1903")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_nukelayer", _(" NukeLayer")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_caltrop", _(" Caltrops")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_mosin", _(" Mosin-Nagant")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_torch", _(" Torch")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_revolver", _(" Revolver")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_mauserpistol", _(" MauserPistol")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bigpistol", _(" .45 Pistol")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m1921", _(" .45 SMG 1921")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_machinepistol", _(" MachinePistol")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";

	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_flashlight", _(" Flashlight")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lrr", _(" LongRangeRifle")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_hellriegelsmg", _(" HellriegelSMG")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	//me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_multitool", _(" Multi-Tool")));
	//	e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_multitool", _("           ")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shortsword", _(" ShortSword")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_webley", _(" Webley")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_broadaxe", _(" BroadAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_longsword", _(" LongSword")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_webleylong", _(" WebleyDragoon")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_rapier", _(" Rapier")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_carbine", _(" Carbine")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_chauchat", _(" Chauchat")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
		
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	//me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_utilitool", _(" Utili-Tool")));
	//	e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_utilitool", _("           ")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shackles", _(" Shackles")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shosho", _(" Sho-Sho")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_spear", _(" Spear")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pdw", _(" PDW")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bar1918", _(" BAR-1918")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightpistol", _(" 9mm Pistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	 me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_morgenstern", _(" Morgenstern")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_nagant1895", _(" Nagant M1895")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_katana", _(" Katana")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_odachi", _(" Odachi")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_mg0815", _(" MG 08/15")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_nagamaki", _(" Nagamaki")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightsabre", _(" Lightsabre")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lewismg", _(" LewisGun")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_tetsubo", _(" Tetsubo")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_largepistol", _(" .50 Pistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightsabreii", _(" LightsabreII")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	
	
		
	
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightauto", _(" 9mm AutoPistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_magnum", _(" 357 Magnum")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightsabreiv", _(" LightsabreIV")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_crowbar", _(" Crowbar")));
		e.colorL = '1 1 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_yari", _(" Yari")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightsabrexi", _(" LightsabreXI")));
		e.colorL = '0.7 1.0 1.0'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_ak47", _(" AK-47")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_rpg7launcher", _(" RPG7")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_sunbeam", _(" Sunbeam")));
		e.colorL = '1.0 1.0 0.7'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_aks74u", _(" AKS-74u")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_tt33pistol", _(" TT33 Pistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_starblast", _(" Starblast")));
		e.colorL = '1.0 1.0 0.7'; e.cvarOffValue = "-1";
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_ffmagnum", _(" 44 Magnum")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m16mini", _(" M16 mini")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_sunburst", _(" Sunburst")));
		e.colorL = '1.0 1.0 0.7'; e.cvarOffValue = "-1";
	
	
	
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m16vn", _(" M16 vn")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_browninghp", _(" 9mm HiPower")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_sunbolt", _(" Sunbolt")));
		e.colorL = '1.0 1.0 0.7'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_longbow", _(" Longbow")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_cudgel", _(" Cudgel")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_starlase", _(" Starlase")));
		e.colorL = '1.0 1.0 0.7'; e.cvarOffValue = "-1";
		
	
	
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_crudebow", _(" Crude Bow")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_compositebow", _(" Composite Bow")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_svd", _(" SVD")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";	
		
		
	
		
		
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_lightcrossbow", _(" Light Crossbow")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_flangedmace", _(" Flanged Mace")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bat", _(" Bat")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_warmallet", _(" War Mallet")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_kiduchi", _(" Kiduchi")));
		e.colorL = '0.75 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_spikedmace", _(" Spiked Mace")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_microuzi", _(" MicroUzi")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_miniuzi", _(" Uzi")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_sai", _(" Sai")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_ra4launcher", _(" RA4")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_stoneaxe", _(" StoneAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_spectre", _(" Spectre")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shiningstar", _(" Shiningstar")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_poleaxe", _(" PoleAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_armingsword", _(" ArmingSword")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_yumibow", _(" Yumi")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_ironcrow", _(" IronCrow")));
		e.colorL = '0.4 0.2 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_defendersword", _(" DefenderSword")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_handcuffs", _(" Handcuffs")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_greyironmallet", _(" GreyIronMallet")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_beardedaxe", _(" BeardedAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_ironknife", _(" Iron Knife")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_dagger", _(" Dagger")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_spikedcudgel", _(" Spiked Cudgel")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_spikedclub", _(" Spiked Club")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_sks45", _(" SKS-45")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bronzecudgel", _(" Bronze Cudgel")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_chainsaw", _(" Chainsaw")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_clawhammer", _(" Claw Hammer")));
		e.colorL = '1 1 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_tec9", _(" Tec-9")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_staffflame", _(" Staff of Flame")));
		e.colorL = '0.2 0.075 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_staffmagi", _(" Magicians Staff")));
		e.colorL = '0.09 0.05 0.1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_poundersmg", _(" Pounder-SMG")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bastardsword", _(" BastardSword")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_scimitar", _(" Scimitar")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_flamethrower", _(" FlameThrower")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_infantryaxe", _(" InfantryAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_elvenaxe", _(" ElvenAxe")));
		e.colorL = '0.05 0.1 0.05'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_devastator", _(" Devastator")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";	
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_quarterstaff", _(" Quarterstaff")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_elvensabre", _(" ElvenSabre")));
		e.colorL = '0.05 0.1 0.05'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_hagar2", _(" Hagar-2")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";	
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_waraxe", _(" WarAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_elvenstaff", _(" ElvenStaff")));
		e.colorL = '0.05 0.1 0.05'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_mortar", _(" MortarCannon")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_powersaw", _(" PowerSaw")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_elvenglaive", _(" ElvenGlaive")));
		e.colorL = '0.05 0.1 0.05'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_l85a2", _(" L85A2")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";	
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_woodaxe", _(" WoodsmansAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_doublebitaxe", _(" DoubleBitAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_fnscar", _(" FN SCAR-H")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_falchion", _(" Falchion")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_axe", _(" Axe")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_g36c", _(" G36C")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pickaxe", _(" Pickaxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_elvenhammer", _(" ElvenHammer")));
		e.colorL = '0.05 0.1 0.05'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_navy1851revolver", _(" Navy1851")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m16a2", _(" M16A2")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	//me.TDempty(me, 0.8);
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pepperboxrevolver", _(" Pepperbox")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_colt44revolver", _(" Colt44")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_musket", _(" Musket")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_flintlockpistol", _(" Flintlock")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_henry1860rifle", _(" HenryRifle")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_eightgaugeshotgun", _(" 8gaShotgun")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_coltlightning", _(" ColtLightning")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_sharpsrifle", _(" SharpsRifle")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_eightgaugesawedoff", _(" 8gaSawedOff")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_tengaugedouble", _(" 10gaDouble")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_tengaugesawedoff", _(" 10gaSawedOff")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bowieknife", _(" BowieKnife")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_arkansastoothpick", _(" ArkansasToothpick")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_milflail", _(" MilitaryFlail")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_infantrystaff", _(" InfantryStaff")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_kriegshammer", _(" KriegsHammer")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_battleaxe", _(" BattleAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bardiche", _(" Bardiche")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_skirmishersaxe", _(" SkirmishersAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_dadao", _(" Dadao")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_tanegashima", _(" Tanegashima")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_crusadersword", _(" CrusaderSword")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_templaraxe", _(" TemplarAxe")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_p90", _(" P90")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_fivesevenpistol", _(" 5.7mm Pistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m93rpistol", _(" 93R Pistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_t17mmrifle", _(" T17mm Rifle")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_famas", _(" FAMAS")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_knife", _(" Knife")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m1928", _(" .45 SMG 1928")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m1929", _(" .45 SMG 1929M")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.075, e = makeXonoticCheckBox(0, "g_start_weapon_svskorpion", _("")));
		e.colorL = '0.25 0.25 0.25'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_svskorpion_altcasings", _("")));
		e.colorL = '0.25 0.25 0.25';
		setDependent(e, "g_start_weapon_svskorpion", 1, 1);
	me.TD(me, 1, 0.675, e = makeXonoticTextLabel(0, _("SV Skorpion")));
		e.colorL = '0.25 0.25 0.25';
	me.TR(me);  me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_czskorpion", _(" CZ Skorpion")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_henry1860maresleg", _(" Mare'sLeg")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_schofieldrevolver", _(" Schofield")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_r1856revolver", _(" Remington1856")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_winchester1873rifle", _(" WinchesterRifle")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_winchester1897", _(" Winchester1897")));
		e.colorL = '0.38 0.38 0.3'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m1897trenchgun", _(" M1897Trenchgun")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_ithacastakeout", _(" IthacaStakeout")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_flamberge", _(" Flamberge")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_streetsweeper", _(" StreetSweeper")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_targetpistol", _(" TargetPistol")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_rpd", _(" RPD")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
		
	
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_m249para", _(" M249Para")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pkm", _(" PKM")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_shirasaya", _(" Shirasaya")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TR(me);  me.TDempty(me, 0.2);
		
		
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_zatoichi", _(" Zatoichi")));
		e.colorL = '0.25 0.00 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_claymore", _(" Claymore")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pudao", _(" Pudao")));
		e.colorL = '0.1 0.05 0.0'; e.cvarOffValue = "-1";
	
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Knowledge:")));
	me.TD(me, 1, 0.22, e = makeXonoticCheckBox(0, "g_start_knowledge_carpentry", _("Car")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.22, e = makeXonoticCheckBox(0, "g_start_knowledge_mortise", _("Mor")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.22, e = makeXonoticCheckBox(0, "g_start_knowledge_stonemasonry", _("Stn")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.22, e = makeXonoticCheckBox(0, "g_start_knowledge_arch", _("Arch")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.22, e = makeXonoticCheckBox(0, "g_start_knowledge_ironworking", _("Iron")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.22, e = makeXonoticCheckBox(0, "g_start_knowledge_welding", _("Wld")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.22, e = makeXonoticCheckBox(0, "g_start_knowledge_concrete", _("Con")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "0";

/////////////////////////////////////////////////
	me.gotoRC(me, 1.5, 1.625); me.setFirstColumn(me, me.currentColumn);
	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("B")));
			e.colorL = '0.7 0.7 0.5';
	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("U")));
			e.colorL = '0.7 0.7 0.5';
	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("I")));
			e.colorL = '0.7 0.7 0.5';
	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("L")));
			e.colorL = '0.7 0.7 0.5';
	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("D")));
			e.colorL = '0.7 0.7 0.5';	

/////////////////////////////////////////////////
	//me.gotoRC(me, 5.75, 1.725); me.setFirstColumn(me, me.currentColumn);
	me.gotoRC(me, 6.5, 1.725); me.setFirstColumn(me, me.currentColumn);

	me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _(" B U I L D I N G S ")));
		e.colorL = '0.7 0.7 0.5';	
/////////////////////////////////////////////////

	//multitool-utilitool
	me.gotoRC(me, 2, 1.725); me.setFirstColumn(me, me.currentColumn);
	//was 1.9, added the 0.06, changed to 1.8, same for below with the 2.3
		
	me.TD(me, 1, 0.55, e = makeXonoticCheckBox(0, "g_balance_multitool_nocost", _(" Zero Build Cost")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.55, e = makeXonoticCheckBox(0, "g_balance_multitool_nobuildtime", _(" Zero Build Time")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.55, e = makeXonoticCheckBox(0, "g_balance_multitool_noknowledgeneeded", _(" Zero Knowledge")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitool_ancientonly", _(" MT: Ancient")));
		e.colorL = '0.85 0.85 0.65';
	
	//me.TR(me);
	me.gotoRC(me, 3.5, 1.725); me.setFirstColumn(me, me.currentColumn);
	me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _(" FreeBuild Blocks")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticSlider(0, 4, 1, "g_balance_multitool_freebuild_blocks"));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_toofarblockscountasbuildings", _("")));
		e.colorL = '0.85 0.85 0.65';
	me.TDempty(me, 0.1);
	me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _(" FreeBuild All")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticSlider(0, 4, 1, "g_balance_multitool_freebuild"));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_ignorebuild_blocks", _("")));
		e.colorL = '0.85 0.85 0.65';
	me.TR(me);
	me.TD(me, 1, 0.45, e = makeXonoticCheckBox(0, "g_balance_multitool_claimstones", _(" Claimstones")));
		e.colorL = '0.85 0.65 0.65';
	me.TDempty(me, 0.1);
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitool_bedspawnpoints", _(" Bed Spawns")));
		e.colorL = '0.85 0.85 0.85'; //Can't change this one for some reason, shows up as '0.85 0.65 0.65' anyway
	
	me.TR(me);
	me.TDempty(me, 0.85);
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noweapons", _(" No Weap")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_nosuits", _(" No Suit")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noaircraft", _(" No Air")));
		e.colorL = '0.85 0.85 0.65';
	
	me.TR(me);
	me.TDempty(me, 0.85);
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noammo", _(" No Ammo")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_nomiscgroundvehicle", _(" No Bulldozer")));
		e.colorL = '0.85 0.85 0.65';
	me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_notanks", _(" No Tanks")));
		e.colorL = '0.85 0.85 0.65';

/////////////////////////////////////////////////
//Multi-Tool custom text (We do the text here so we can still click on the whole text since the Checkbox is big above)
//If we did it another way you would have to be very accurate and click the checkbox exactly and not the words.
	me.gotoRC(me, 26, 0); me.setFirstColumn(me, me.currentColumn);
		me.TDempty(me, 0.28);
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("M")));

			e.colorL = '0.3 0.15 0.0';	
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("u")));

			e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("l")));

			e.colorL = '0.3 0.15 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("t")));

			e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("i")));

			e.colorL = '0.3 0.15 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("-")));

			e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("T")));

			e.colorL = '0.3 0.15 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("o")));

			e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("o")));

			e.colorL = '0.3 0.15 0.0';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("l")));

			e.colorL = '0.1 0.05 0.0';
		//me.TDempty(me, 0.17);	
/////////////////////////////////////////////////
/////////////////////////////////////////////////
//Utili-Tool custom text (We do the text here so we can still click on the whole text since the Checkbox is big above)
//If we did it another way you would have to be very accurate and click the checkbox exactly and not the words.
	me.gotoRC(me, 29, 0); me.setFirstColumn(me, me.currentColumn);
		me.TDempty(me, 0.28);
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("U")));

			e.colorL = '1.0 1.0 0.7';	
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("t")));

			e.colorL = '0.7 0.7 0.5';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("i")));

			e.colorL = '1.0 1.0 0.7';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("l")));

			e.colorL = '0.7 0.7 0.5';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("i")));

			e.colorL = '1.0 1.0 0.7';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("-")));

			e.colorL = '0.7 0.7 0.5';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("T")));

			e.colorL = '1.0 1.0 0.7';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("o")));

			e.colorL = '0.7 0.7 0.5';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("o")));

			e.colorL = '1.0 1.0 0.7';
		me.TD(me, 1, 0.055, e = makeXonoticTextLabel(0, _("l")));

			e.colorL = '0.7 0.7 0.5';
		//me.TDempty(me, 0.17);	
/////////////////////////////////////////////////


/////////////////////////////////////////////////
	me.gotoRC(me, 9, 2.6); me.setFirstColumn(me, me.currentColumn);
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Additional Items")));
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 1000, 1, "g_randomadditionalitems"));
	me.TD(me, 1, 0.2, e = makeXonoticSlider(0, 500, 2, "g_randomadditionalitems_wait"));
	me.TR(me);
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Nails")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.04, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_nails_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Rockets")));
		e.colorL = '1.0 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.04, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_rockets_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Cells")));
		e.colorL = '0.5 0.75 1.0'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.04, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_cells_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Shells")));
		e.colorL = '0.75 0.75 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.04, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_shells_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	me.TR(me);
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Fuel")));
		e.colorL = '0.25 0.25 0.0'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.04, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_fuel_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	me.TR(me);
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Grenades")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_grenades_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Fragnades")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_fragnades_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Flashbangs")));
		e.colorL = '0.25 0.1 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_flashbangs_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Smokenades")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_smokenades_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Landmines")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_landmines_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("AT Mines")));
		e.colorL = '1.0 0.5 0.0'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_atmines_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	
	me.TR(me);
	me.TR(me);
	
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.26, e = makeXonoticTextLabel(0, _("Small")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticTextLabel(0, _("Med")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticTextLabel(0, _("Big")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticTextLabel(0, _("Huge")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Armor")));
		e.colorL = '0.5 1.0 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_armor_small_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_armor_medium_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_armor_big_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_armor_large_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Health")));
		e.colorL = '1.0 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_health_small_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_health_medium_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_health_large_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_health_mega_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Health Potion")));
		e.colorL = '1.0 0.0 0.0'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_potion_health_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Potion of Mana")));
		e.colorL = '0.0 0.0 1.0'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_potion_mana_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Potion of Rejuvenation")));
		e.colorL = '1.0 1.0 0.0'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_potion_rejuv_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Scrolls")));
		e.colorL = '0.7 0.65 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_scroll_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
		me.TDempty(me, 0.4);
		me.TD(me, 1, 0.25, e = makeXonoticCommandButton(ZCTX(_("PRE^Scrolls")), '0.7 0.65 0.5', "exec button_replace_weapon_scrollonly.cfg", 0));
			setDependentAND(e, "g_randomadditionalitems", 1, 10000000,
			"randomadditionalitems_scroll_amnt", 0.0001, 1);
		me.TD(me, 1, 0.25, e = makeXonoticCommandButton(ZCTX(_("PRE^S+MedeB")), '0.7 0.65 0.5', "exec button_replace_weapon_scrollandbookknowmed.cfg", 0));
			setDependentAND(e, "g_randomadditionalitems", 1, 10000000,
			"randomadditionalitems_scroll_amnt", 0.0001, 1);
		me.TD(me, 1, 0.25, e = makeXonoticCommandButton(ZCTX(_("PRE^S+All B")), '0.7 0.65 0.5', "exec button_replace_weapon_scrollandbookknowall.cfg", 0));
			setDependentAND(e, "g_randomadditionalitems", 1, 10000000,
			"randomadditionalitems_scroll_amnt", 0.0001, 1);
		me.TD(me, 1, 0.25, e = makeXonoticCommandButton(ZCTX(_("PRE^Books")), '0.7 0.65 0.5', "exec button_replace_weapon_bookknowonly.cfg", 0));
			setDependentAND(e, "g_randomadditionalitems", 1, 10000000,
			"randomadditionalitems_scroll_amnt", 0.0001, 1);
	me.TR(me);
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Spell Books")));
		e.colorL = '0.6 0.5 0.6'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_spellbook_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TR(me);
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Skill Books")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_skillbook_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TR(me);
	
	me.TR(me);
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Water")));
		e.colorL = '0.5 0.65 0.75'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_potion_water_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Ale")));
		e.colorL = '0.7 0.7 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_potion_ale_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Vodka")));
		e.colorL = '0.65 0.65 0.65'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_potion_vodka_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Merlot")));
		e.colorL = '0.7 0.0 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_potion_merlot_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	
	me.TR(me);
	
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Bread")));
		e.colorL = '0.75 0.65 0.4'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_bread_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Cheeze")));
		e.colorL = '0.8 0.8 0.25'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_cheeze_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Garlic")));
		e.colorL = '0.65 0.6 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_garlic_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Grapes")));
		e.colorL = '0.65 0.25 0.75'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_grapes_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Onion")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_onion_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("Tomato")));
		e.colorL = '0.85 0.25 0.0'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_tomato_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("BellPepper")));
		e.colorL = '0.65 1.0 0.65'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_bellpepper_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 0.30, e = makeXonoticTextLabel(0, _("TurkeyLeg")));
		e.colorL = '0.5 0.5 0.3'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.40, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_food_turkeyleg_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	
	me.TR(me);
	
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.26, e = makeXonoticCheckBox(0, "g_balance_uzi_suppressornotincluded", _("Mac10")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.14, e = makeXonoticCheckBox(0, "g_balance_bigpistol_suppressornotincluded", _(".45")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.12, e = makeXonoticCheckBox(0, "g_balance_longpistol_suppressornotincluded", _("")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);	
	me.TD(me, 1, 0.14, e = makeXonoticCheckBox(0, "g_balance_lightpistol_suppressornotincluded", _("9mm")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.12, e = makeXonoticCheckBox(0, "g_balance_lightauto_suppressornotincluded", _("")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticCheckBox(0, "g_balance_rifle_suppressornotincluded", _("Rifle")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Suppressors")));
		e.colorL = '0.8 0.8 0.8'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_suppressormac10_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_suppressor45_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_suppressor9mm_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_suppressorrifle_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	
	
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.26, e = makeXonoticCheckBox(0, "g_balance_fivesevenpistol_suppressornotincluded", _("5.7mm")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.26, e = makeXonoticCheckBox(0, "g_balance_pdw_suppressornotincluded", _("PDW")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	me.TDempty(me, 0.36);
		me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_suppressor5n7mm_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
		me.TD(me, 1, 0.26, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_suppressorpdw_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("Cylinders")));
		e.colorL = '0.8 0.8 0.8'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 1.04, e = makeXonoticCheckBox(0, "g_balance_r1856revolver_extracylindernotincluded", _("Remington1856")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TR(me);
	me.TDempty(me, 0.36);
		me.TD(me, 1, 1.04, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_cylinder_r1856_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	
	me.TR(me);
	me.TD(me, 1, 0.36, e = makeXonoticTextLabel(0, _("ExtendedMags")));
		e.colorL = '0.8 0.8 0.8'; e.cvarOffValue = "-1";
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_ak47_exmag50notincluded", _("AK-47 50rnd")));
		e.colorL = '0.2 0.075 0.0'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_ak47_exmag100notincluded", _("AK-47 100rnd")));
		e.colorL = '0.2 0.075 0.0'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_ak47_50_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_ak47_100_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	
	
	//AK Drums
	
	me.TR(me);
		me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_ak47_drum75notincluded", _("AK-47 75rnd")));
		e.colorL = '0.2 0.075 0.0'; e.cvarOffValue = "-1";	
	//me.TD(me, 1, 0.52, e = makeXonoticTextLabel(0, _("AK-47 30rnd")));
	//	e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	//	//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_drum_ak47_75_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 10000000);
	//me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_mag_ak47_30_amnt"));
	//	setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	
	
	//UZI:
	
	//me.TR(me);
	//me.TDempty(me, 0.36);
	
	//me.TD(me, 1, 0.52, e = makeXonoticTextLabel(0, _("UZI 20rnd")));
	//	e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	//	//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	//me.TR(me);
	//
	//me.TDempty(me, 0.36);
	//me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_mag_uzi_20_amnt"));
	//	setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	
	//UZI:
	
	//me.TR(me);
	//me.TDempty(me, 0.36);
	
	//me.TD(me, 1, 0.52, e = makeXonoticTextLabel(0, _("UZI 25rnd")));
	//	e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	//	//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	//me.TD(me, 1, 0.52, e = makeXonoticTextLabel(0, _("UZI 32rnd")));
	//	e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
	//	//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	//me.TR(me);
	
	//me.TDempty(me, 0.36);
	//me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_mag_uzi_25_amnt"));
	//	setDependent(e, "g_randomadditionalitems", 1, 5000000);
	//me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_mag_uzi_32_amnt"));
	//	setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	
	//
	
	me.TR(me);
	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_microuzi_exmag40notincluded", _("")));
	me.TD(me, 1, 0.47, e = makeXonoticCheckBox(0, "g_balance_miniuzi_exmag40notincluded", _("UZI 40rnd")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_microuzi_exmag50notincluded", _("")));
	me.TD(me, 1, 0.47, e = makeXonoticCheckBox(0, "g_balance_miniuzi_exmag50notincluded", _("UZI 50rnd")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_uzi_40_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_uzi_50_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	
	//UZI:
	
	me.TR(me);
	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_microuzi_drum82notincluded", _("")));
	me.TD(me, 1, 0.47, e = makeXonoticCheckBox(0, "g_balance_miniuzi_drum82notincluded", _("UZI 82rnd")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_microuzi_exmag106notincluded", _("")));	
	me.TD(me, 1, 0.47, e = makeXonoticCheckBox(0, "g_balance_miniuzi_exmag106notincluded", _("UZI 106rnd")));
		e.colorL = '0.5 0.5 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_drum_uzi_82_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_uzi_106_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
		
/////////////////////////////////////////////////

	me.TR(me);
	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_aks74u_exmag45notincluded", _("AK74 45rnd")));
		e.colorL = '0.6 0.3 0.0'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_ak74_45_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	
	

/////////////////////////////////////////////////
	me.TR(me);

	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_tec9_exmag36notincluded", _("TEC9 36rnd")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_tec9_exmag50notincluded", _("TEC9 50rnd")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_tec9_36_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_tec9_50_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	
	//TEC9:
	
	me.TR(me);
	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_tec9_drum72notincluded", _("TEC9 72rnd")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_drum_tec9_72_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	

/////////////////////////////////////////////////

	me.TR(me);
	me.TDempty(me, 0.36);

	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_m16a2_betacmagnotincluded", _("")));	
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_m16vn_betacmagnotincluded", _("")));
	me.TD(me, 1, 0.42, e = makeXonoticCheckBox(0, "g_balance_m16mini_betacmagnotincluded", _("M16 BetaCMag")));
		e.colorL = '0.45 0.45 0.5'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_betacmag_m16_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
/////////////////////////////////////////////////
	me.TR(me);

	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_lightpistol_drumnotincluded", _("")));
	me.TD(me, 1, 0.47, e = makeXonoticCheckBox(0, "g_balance_lightauto_drumnotincluded", _("9mm Drum")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_lightpistol_betacmagnotincluded", _("")));
	me.TD(me, 1, 0.47, e = makeXonoticCheckBox(0, "g_balance_lightauto_betacmagnotincluded", _("9mm BetaCMag")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_drum_lightpistol_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_betacmag_lightpistol_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
		
/////////////////////////////////////////////////
	me.TR(me);

	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_pdw_exmag40notincluded", _("PDW 40rnd")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_pdw_drumnotincluded", _("PDW Drum")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag40_pdw_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_drum_pdw_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
		
/////////////////////////////////////////////////
	
	me.TR(me);

	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_pdw_betacmagnotincluded", _("PDW BetaCMag")));
		e.colorL = '0.2 0.2 0.2'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_betacmag_pdw_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
		
/////////////////////////////////////////////////
/////////////////////////////////////////////////
	me.gotoRC(me, 52, 3.12); me.setFirstColumn(me, me.currentColumn);

	me.TR(me);

	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_lightpistol_exmagnotincluded", _("9mm 31rnd")));
		e.colorL = '0.3 0.3 0.3'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);

	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_lightpistol_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
/////////////////////////////////////////////////

/////////////////////////////////////////////////
	me.gotoRC(me, 58, 3.12); me.setFirstColumn(me, me.currentColumn);

	me.TR(me);
	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_styeraug_exmag42notincluded", _("StyerAug 42rnd")));
		e.colorL = '0.4 0.5 0.3'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_styeraug_42_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
/////////////////////////////////////////////////
	me.TR(me);
	me.TR(me);
	
/////////////////////////////////////////////////	
	me.TR(me);
	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_bar1918_exmag40notincluded", _("BAR-1918 40rnd")));
		e.colorL = '0.65 0.65 0.65'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_exmag_bar_40_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
/////////////////////////////////////////////////

	me.TR(me);
	me.TDempty(me, 0.36);
	
	me.TD(me, 1, 0.52, e = makeXonoticCheckBox(0, "g_balance_lewismg_panmag97notincluded", _("LewisGun 97rnd")));
		e.colorL = '0.3795 0.375 0.2475'; e.cvarOffValue = "-1";
		//setDependent(e, "g_randomadditionalitems", 1, 5000000);
	
	me.TR(me);
	
	me.TDempty(me, 0.36);
	me.TD(me, 1, 0.52, e = makeXonoticSlider(0, 1, 0.01, "randomadditionalitems_misc_panmag_lewisgun_97_amnt"));
		setDependent(e, "g_randomadditionalitems", 1, 5000000);
			

	
/////////////////////////////////////////////////
	
	
	me.TR(me); me.TDempty(me, 0.2);
	

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticStartweaponsdmDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticStartweaponsdmDialog).close(me);
}
#endif
