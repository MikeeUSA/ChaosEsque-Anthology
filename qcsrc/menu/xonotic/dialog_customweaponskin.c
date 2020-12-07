#ifdef INTERFACE
CLASS(XonoticCustomWeaponSkinDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticCustomWeaponSkinDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	METHOD(XonoticCustomWeaponSkinDialog, showNotify, void(entity))
	ATTRIB(XonoticCustomWeaponSkinDialog, title, string, _("Custom Weapon Skin")) // ;)
	ATTRIB(XonoticCustomWeaponSkinDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticCustomWeaponSkinDialog, intendedWidth, float, 0.9)
	ATTRIB(XonoticCustomWeaponSkinDialog, rows, float, 11)
	ATTRIB(XonoticCustomWeaponSkinDialog, columns, float, 4)
	ATTRIB(XonoticCustomWeaponSkinDialog, name, string, "CustomWeaponSkin")
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_default, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_zero, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_one, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_two, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_three, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_four, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_five, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_six, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_seven, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_eight, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_nine, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_ten, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_eleven, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_twelve, entity, NULL)
	ATTRIB(XonoticCustomWeaponSkinDialog, customweaponskin_none, entity, NULL)
	
ENDCLASS(XonoticCustomWeaponSkinDialog)
#endif

#ifdef IMPLEMENTATION
entity makeCustomWeaponSkinButton(string theName, vector theColor, string commandtheName)
{
	entity b;
	b = makeXonoticBigCommandButton(theName, theColor, commandtheName, 1);
	return b;
}

void XonoticCustomWeaponSkinDialog_showNotify(entity me)
{
	float cwsclass_ld, cwsclass_md, cwsclass_as;
	float cwsclass_cr, cwsclass_de, cwsclass_hw;
	float cwsclass_py, cwsclass_en, cwsclass_wk;
	float cwsclass_hl, cwsclass_el, cwsclass_tw;
	float cwsclass_zr;
	float cwsclass_mk;
	float cwsclass_none;
	float cwsclassset;
	
	vector mycolormap_c0, mycolormap_c1, mycolormap_c2, mycolormap_c2lightened;
	
	mycolormap_c0 = colormapPaletteColor(floor(  cvar("_cl_color") / 16), 0); //Shirt
	mycolormap_c1 = colormapPaletteColor(mod(  cvar("_cl_color") , 16), 1);    //Pants
	mycolormap_c2 = mycolormap_c0+mycolormap_c1;
	mycolormap_c2lightened = mycolormap_c2;
	mycolormap_c2lightened_x = (mycolormap_c2lightened_x * 0.5) + 0.5;
	mycolormap_c2lightened_y = (mycolormap_c2lightened_y * 0.5) + 0.5;
	mycolormap_c2lightened_z = (mycolormap_c2lightened_z * 0.5) + 0.5;
	
	//cwsclass_ld = cvar("_customweaponskin_default");
	//cwsclass_zr = cvar("_customweaponskin_zero");
	//cwsclass_mk = cvar("_customweaponskin_one");
	//cwsclass_md = cvar("_customweaponskin_two");
	//cwsclass_as = cvar("_customweaponskin_three");
	//cwsclass_cr = cvar("_customweaponskin_four");
	//cwsclass_de = cvar("_customweaponskin_five");
	//cwsclass_hw = cvar("_customweaponskin_six");
	//cwsclass_py = cvar("_customweaponskin_pyromaniac");
	//cwsclass_en = cvar("_customweaponskin_eight");
	//cwsclass_wk = cvar("_customweaponskin_nine");
	//cwsclass_hl = cvar("_customweaponskin_ten");
	//cwsclass_el = cvar("_customweaponskin_eleven");
	//cwsclass_tw = cvar("_customweaponskin_twelve");
	//cwsclass_none = 1;
	
	cwsclassset = cvar("_activeweapon");
	//cwsclassset = 0; //Disabled for now
	
	//me.customweaponskin_default.disabled = !(cwsclass_ld);
	//me.customweaponskin_zero.disabled = !(cwsclass_zr);
	//me.customweaponskin_one.disabled = !(cwsclass_mk);
	//me.customweaponskin_two.disabled = !(cwsclass_md);
	//me.customweaponskin_three.disabled = !(cwsclass_as);
	//me.customweaponskin_four.disabled = !(cwsclass_cr);
	//me.customweaponskin_five.disabled = !(cwsclass_de);
	//me.customweaponskin_six.disabled = !(cwsclass_hw);
	//me.customweaponskin_seven.disabled = !(cwsclass_py);
	//me.customweaponskin_eight.disabled = !(cwsclass_en);
	//me.customweaponskin_nine.disabled = !(cwsclass_wk);
	//me.customweaponskin_ten.disabled = !(cwsclass_hl);
	//me.customweaponskin_eleven.disabled = !(cwsclass_el);
	//me.customweaponskin_twelve.disabled = !(cwsclass_tw);
	//me.customweaponskin_none.disabled = !(cwsclass_none);


//set all to enabled
	me.customweaponskin_default.disabled = 0;
	me.customweaponskin_zero.disabled = 0;
	me.customweaponskin_one.disabled = 0;
	me.customweaponskin_two.disabled = 0;
	me.customweaponskin_three.disabled = 0;
	me.customweaponskin_four.disabled = 0;
	me.customweaponskin_five.disabled = 0;
	me.customweaponskin_six.disabled = 0;
	me.customweaponskin_seven.disabled = 0;
	me.customweaponskin_eight.disabled = 0;
	me.customweaponskin_nine.disabled = 0;
	me.customweaponskin_ten.disabled = 0;
	me.customweaponskin_eleven.disabled = 0;
	me.customweaponskin_twelve.disabled = 0;
	me.customweaponskin_none.disabled = 0;
	
	//Here we configure non-default playerclasses	
	//entity cws_ld, cws_mk, cws_md, cws_as, cws_cr;
	//entity cws_de, cws_hw, cws_py, cws_en, cws_wk;
	//entity cws_hl,
	
	entity cws_ld = me.customweaponskin_default;
	entity cws_zr = me.customweaponskin_zero;
	entity cws_mk = me.customweaponskin_one;
	entity cws_md = me.customweaponskin_two;
	entity cws_as = me.customweaponskin_three;
	entity cws_cr = me.customweaponskin_four;
	entity cws_de = me.customweaponskin_five;
	entity cws_hw = me.customweaponskin_six;
	entity cws_py = me.customweaponskin_seven;
	entity cws_en = me.customweaponskin_eight;
	entity cws_wk = me.customweaponskin_nine;
	entity cws_hl = me.customweaponskin_ten;
	entity cws_el = me.customweaponskin_eleven;
	entity cws_tw = me.customweaponskin_twelve;
	
	
	if (cwsclassset == -999) {
	//Reserved.. for the future
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("Default"), '0.9 0.9 0.9', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("Zero"), '0.9 0.9 0.9', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("One"), '0.7 0.7 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("Two"), '0.7 0.6 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("Three"), '0.7 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("Four"), '0.7 0.5 0.3', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("Five"), '0.5 0.3 0.2', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("Six"), '0.3 0.3 0.3', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("Seven"), '0.1 0.1 0.1', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("Eight"), '0.2 0.2 0.2', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("Nine"), '0.7 0.6 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("Ten"), '0.6 0.7 0.6', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("Eleven"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("Twelve"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_BIGPISTOL) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _(".45 Pistol Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Classic"), '0.5 0.45 0.4', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Fancy"), '0.8 0.8 0.8', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Govt"), '0.1 0.1 0.1', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_TARGETPISTOL) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("TargetPistol Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Classic"), '0.7 0.5 0.3', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Black with Shining Barrel"), '0.1 0.1 0.1', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2"), '0.5 0.5 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_STREETSWEEPER) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("StreetSweeper Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Tan"), '0.7 0.6 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 White"), '1.0 1.0 1.0', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_PDW) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("PDW Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Colormapped"), mycolormap_c2, "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Shining"), '0.8 0.8 0.8', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_LIGHTAUTO) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("9mm AutoPistol Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Tan"), '0.7 0.6 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 White"), '1.0 1.0 1.0', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Colormapped"), mycolormap_c2, "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 Pink"), '1 0.8 0.8', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_LARGEPISTOL) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _(".50 Pistol Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Shiny"), '0.8 0.8 0.8', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Gold and Copper Tigerstripes"), '1 1 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Colormapped Tigerstripes"), mycolormap_c2lightened, "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 White Tigerstripes"), '1 1 1', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_M82RIFLE) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("M82 Rifle Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Tan"), '0.7 0.6 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 White"), '1.0 1.0 1.0', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Pink"), '1 0.55 0.75', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 Colormapped"), mycolormap_c2, "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5 Shiny"), '0.85 0.85 0.85', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6 Shiny Old"), '1 0.9 0.8', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7 Shiny Blueish"), '0.75 0.90 1', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8 Shiny Yellowish"), '1 0.90 0.75', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9 Gold and Copper Tigerstripes"), '1 1 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10 White Tigerstripes"), '1 1 1', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11 Colormapped Tigerstripes"), mycolormap_c2lightened, "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_AK47) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("AK-47 Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Silver"), '0.85 0.85 0.85', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Gold"), '1 1 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_TT33PISTOL) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("TT33 Pistol Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Silver"), '0.85 0.85 0.85', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Gold"), '1 1 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Red"), '1 0.0 0.0', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_FAMAS) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("FAMAS Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Tan"), '0.7 0.6 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Other"), '0.5 0.5 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Olive"), '0.6 0.7 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 White"), '1 1 1', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5 Colormapped"), mycolormap_c2, "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_KNIFE) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("Knife Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Steel"), '0.75 0.75 0.75', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Tan"), '0.7 0.6 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Red"), '1 0 0', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Green"), '0.2 0.6 0.2', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 White"), '1 1 1', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5 Colormapped"), mycolormap_c2, "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6 Brass"), '0.78 0.75 0.3', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_STYERAUG) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("StyerAug Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Olive"), '0.6 0.7 0.5', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 White"), '1 1 1', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Black"), '0.1 0.1 0.1', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Colormapped"), mycolormap_c2, "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 Pink"), '1 0.8 0.8', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_P90) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("P90 Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Black"), '0.1 0.1 0.1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Tan"), '0.7 0.6 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Pink"), '1 0.6 0.73', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Olive"), '0.6 0.7 0.5' , "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 White"), '1 1 1', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5 Colormapped"), mycolormap_c2, "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_LEWISMG) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("LewisGun Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Standard"), '0.65 0.6 0.5', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Snow"), '1 1 1', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2 Desert"), '0.7 0.6 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3 Black"), '0.1 0.1 0.1' , "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4 Colormapped"), mycolormap_c2, "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_CRYLINK) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("Crylink Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Default Color"), '1 0.5 1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Colormapped"), mycolormap_c2, "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2"), '0.5 0.5 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else if (cwsclassset == WEP_ELECTRO) { 
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("Electro Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0 Default Color"), '0.5 0.5 1', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1 Colormapped"), mycolormap_c2, "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2"), '0.5 0.5 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	
	} else {
		cws_ld.configureXonoticBigCommandButton(cws_ld, _("Default"), '0.5 0.5 0.5', "cmd customweaponskin 0", 1);
		cws_zr.configureXonoticBigCommandButton(cws_zr, _("0"), '0.5 0.5 0.5', "cmd customweaponskin -1", 1);
		cws_mk.configureXonoticBigCommandButton(cws_mk, _("1"), '0.5 0.5 0.5', "cmd customweaponskin 1", 1);
		cws_md.configureXonoticBigCommandButton(cws_md, _("2"), '0.5 0.5 0.5', "cmd customweaponskin 2", 1);
		cws_as.configureXonoticBigCommandButton(cws_as, _("3"), '0.5 0.5 0.5', "cmd customweaponskin 3", 1);
		cws_cr.configureXonoticBigCommandButton(cws_cr, _("4"), '0.5 0.5 0.5', "cmd customweaponskin 4", 1);
		cws_de.configureXonoticBigCommandButton(cws_de, _("5"), '0.5 0.5 0.5', "cmd customweaponskin 5", 1);
		cws_hw.configureXonoticBigCommandButton(cws_hw, _("6"), '0.5 0.5 0.5', "cmd customweaponskin 6", 1);
		cws_py.configureXonoticBigCommandButton(cws_py, _("7"), '0.5 0.5 0.5', "cmd customweaponskin 7", 1);
		cws_en.configureXonoticBigCommandButton(cws_en, _("8"), '0.5 0.5 0.5', "cmd customweaponskin 8", 1);
		cws_wk.configureXonoticBigCommandButton(cws_wk, _("9"), '0.5 0.5 0.5', "cmd customweaponskin 9", 1);
		cws_hl.configureXonoticBigCommandButton(cws_hl, _("10"), '0.5 0.5 0.5', "cmd customweaponskin 10", 1);
		cws_el.configureXonoticBigCommandButton(cws_el, _("11"), '0.5 0.5 0.5', "cmd customweaponskin 11", 1);
		cws_tw.configureXonoticBigCommandButton(cws_tw, _("12"), '0.5 0.5 0.5', "cmd customweaponskin 12", 1);
	}
}

void XonoticCustomWeaponSkinDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 4, me.customweaponskin_none = makeCustomWeaponSkinButton(_("No Change"), '0.5 0.5 0.5', "cmd customweaponskin"));
	me.TR(me);
		me.TD(me, 2, 4, me.customweaponskin_default = makeCustomWeaponSkinButton(_("Default"), '0.5 0.5 0.5', "cmd customweaponskin 0"));		
	me.TR(me);
	me.TR(me);	
		me.TD(me, 2, 1, me.customweaponskin_zero = makeCustomWeaponSkinButton(_("0"), '0.5 0.5 0.5', "cmd customweaponskin -1"));
		me.TD(me, 2, 1, me.customweaponskin_one = makeCustomWeaponSkinButton(_("1"), '0.5 0.5 0.5', "cmd customweaponskin 1"));
		me.TD(me, 2, 1, me.customweaponskin_two = makeCustomWeaponSkinButton(_("2"), '0.5 0.5 0.5', "cmd customweaponskin 2"));
		me.TD(me, 2, 1, me.customweaponskin_three = makeCustomWeaponSkinButton(_("3"), '0.5 0.5 0.5', "cmd customweaponskin 3"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.customweaponskin_four = makeCustomWeaponSkinButton(_("4"), '0.5 0.5 0.5', "cmd customweaponskin 4"));
		me.TD(me, 2, 1, me.customweaponskin_five = makeCustomWeaponSkinButton(_("5"), '0.5 0.5 0.5', "cmd customweaponskin 5"));
		me.TD(me, 2, 1, me.customweaponskin_six = makeCustomWeaponSkinButton(_("6"), '0.5 0.5 0.5', "cmd customweaponskin 6"));
		me.TD(me, 2, 1, me.customweaponskin_seven = makeCustomWeaponSkinButton(_("7"), '0.5 0.5 0.5', "cmd customweaponskin 7"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.customweaponskin_eight = makeCustomWeaponSkinButton(_("8"), '0.5 0.5 0.5', "cmd customweaponskin 8"));
		me.TD(me, 2, 1, me.customweaponskin_nine = makeCustomWeaponSkinButton(_("9"), '0.5 0.5 0.5', "cmd customweaponskin 9"));
		me.TD(me, 2, 1, me.customweaponskin_ten = makeCustomWeaponSkinButton(_("10"), '0.5 0.5 0.5', "cmd customweaponskin 10"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.customweaponskin_eleven = makeCustomWeaponSkinButton(_("11"), '0.5 0.5 0.5', "cmd customweaponskin 11"));
		me.TD(me, 2, 1, me.customweaponskin_twelve = makeCustomWeaponSkinButton(_("12"), '0.5 0.5 0.5', "cmd customweaponskin 12"));
	me.TR(me);
	//me.TR(me);
		//me.TD(me, 2, 4, me.customweaponskin_none = makeCustomWeaponSkinButton(_("None"), '0.5 0.5 0.5', "cmd customweaponskin none"));
	//me.TR(me);


}
#endif

/* Click. The c-word is here so you can grep for it :-) */
