#ifdef INTERFACE
CLASS(XonoticAudioSettingsTab) EXTENDS(XonoticTab)
	METHOD(XonoticAudioSettingsTab, fill, void(entity))
	ATTRIB(XonoticAudioSettingsTab, title, string, _("Audio"))
	ATTRIB(XonoticAudioSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticAudioSettingsTab, rows, float, 17)
	ATTRIB(XonoticAudioSettingsTab, columns, float, 6.2) // added extra .2 for center space 
ENDCLASS(XonoticAudioSettingsTab)
entity makeXonoticAudioSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticAudioSettingsTab()
{
	entity me;
	me = spawnXonoticAudioSettingsTab();
	me.configureDialog(me);
	return me;
}

void XonoticAudioSettingsTab_fill(entity me)
{
	entity e, s, sl;

	me.TR(me);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "mastervolume");
		me.TD(me, 1, 1, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Master:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "bgmvolume");
		makeMulti(s, "snd_channel8volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Music:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_staticvolume");
		makeMulti(s, "snd_channel9volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, ZCTX(_("VOL^Ambient:"))));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_channel0volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Info:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_channel3volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Items:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_channel6volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Pain:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_channel7volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Player:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_channel4volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Shots:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_channel2volume");
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Voice:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticDecibelsSlider(-40, 0, 1, "snd_channel1volume");
		makeMulti(s, "snd_channel5volume"); // @!#%'n Tuba
		me.TD(me, 1, 0.8, e = makeXonoticSliderCheckBox(-1000000, 1, s, _("Weapons:")));
		if(s.value != e.savedValue)
			e.savedValue = 0; // default
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "mastervolume", "0");
		setDependentStringNotEqual(s, "mastervolume", "0");
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticCheckBox(0, "menu_snd_attenuation_method", _("New style sound attenuation")));
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticCheckBox(0, "snd_mutewhenidle", _("Mute sounds when not active")));
	
	me.TR(me);
	me.TR(me);
	//The formula is Semitones = 12 * log(freq/440) / log(2) 
	//440hz = 0, 432 hz = -0.31767
	me.TD(me, 1, 2, makeXonoticTextLabel(0, _("Instrument (Tuba/Etc) Concert A Pitch:")));
		me.TD(me, 1, 4.2, e = makeXonoticTextSlider("g_balance_tuba_concertadeviation"));
			e.addValue(e, _("400 Hz"), "-1.65004");
			e.addValue(e, _("409 Hz (Handel)"), "-1.26483"); //Earlier
			e.addValue(e, _("415 Hz *Baroque*"), "-1.01270");
			e.addValue(e, _("421 Hz (Leipzig)"), "-0.76419");
			e.addValue(e, _("422.5 Hz (Handel)"),"-0.70262"); //Later
			e.addValue(e, _("423.2 Hz (Dresden 1815)"),"-0.67396"); //Earlier
			e.addValue(e, _("425 Hz (Haydn)"), "-0.60048");
			e.addValue(e, _("430 Hz (Mozart)"), "-0.39800");
			e.addValue(e, _("435 Hz (French)"),"-0.19785"); //11 Years Later //Dresden 1826
			e.addValue(e, _("435.5 Hz (diapason normal)"),"-0.17796"); //Bach Choir, Felix Mottl, Artur Nikisch
			e.addValue(e, _("432 Hz *Classical*"), "-0.31767");
			e.addValue(e, _("439 Hz (New Philharmonic )"), "-0.03939");
			e.addValue(e, _("440 Hz *Standard*"), "0");
			e.addValue(e, _("442 Hz (Alt Europe)"), "0.07851");
			e.addValue(e, _("443 Hz (Alt Europe)"), "0.11763"); //Russia/Sweden/Spain
			e.addValue(e, _("451 Hz (La Scala)"), "0.42748");
			e.addValue(e, _("452 Hz (Old Philharmonic)"), "0.46583");
			e.addValue(e, _("466 Hz (*Chorton*)"), "0.99391"); //Chapel Royal
			e.addValue(e, _("470 Hz"), "1.14188");
			e.addValue(e, _("480 Hz"), "1.50637");
			e.configureXonoticTextSliderValues(e);
	
	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, makeXonoticTextLabel(0, _("Frequency:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("snd_speed"));
			e.addValue(e, _("8 kHz"), "8000");
			e.addValue(e, _("11.025 kHz"), "11025");
			e.addValue(e, _("16 kHz"), "16000");
			e.addValue(e, _("22.05 kHz"), "22050");
			e.addValue(e, _("24 kHz"), "24000");
			e.addValue(e, _("32 kHz"), "32000");
			e.addValue(e, _("44.1 kHz"), "44100");
			e.addValue(e, _("48 kHz"), "48000");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, makeXonoticTextLabel(0, _("Channels:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("snd_channels"));
			e.addValue(e, _("Mono"), "1");
			e.addValue(e, _("Stereo"), "2");
			e.addValue(e, _("2.1"), "3");
			e.addValue(e, _("4"), "4");
			e.addValue(e, _("5"), "5");
			e.addValue(e, _("5.1"), "6");
			e.addValue(e, _("6.1"), "7");
			e.addValue(e, _("7.1"), "8");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1.2, e = makeXonoticCheckBox(0, "snd_swapstereo", _("Swap Stereo")));
		setDependent(e, "snd_channels", 1.5, 0.5);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "snd_spatialization_control", _("Headphone friendly mode")));
		setDependent(e, "snd_channels", 1.5, 0.5);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticCheckBox(0, "cl_hitsound", _("Hit indication sound")));
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticCheckBox(0, "con_chatsound", _("Chat message sound")));
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticCheckBoxEx(2, 0, "menu_sounds", _("Menu sounds")));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, makeXonoticTextLabel(0, _("Time announcer:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("cl_announcer_maptime"));
			e.addValue(e, ZCTX(_("WRN^Disabled")), "0");
			e.addValue(e, _("1 minute"), "1");
			e.addValue(e, _("5 minutes"), "2");
			e.addValue(e, ZCTX(_("WRN^Both")), "3");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
	me.TR(me);
		sl = makeXonoticSlider(0.15, 1, 0.05, "cl_autotaunt");
			sl.valueDisplayMultiplier = 100;
			sl.valueDigits = 0;
		me.TD(me, 1, 3, e = makeXonoticSliderCheckBox(0, 1, sl, _("Automatic taunts")));
		if(sl.value != e.savedValue)
			e.savedValue = 0.65; // default
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, makeXonoticTextLabel(0, _("Frequency:")));
		me.TD(me, 1, 2, sl);
	me.TR(me);
	me.TR(me);
		if(cvar("developer"))
			me.TD(me, 1, 3, makeXonoticCheckBox(0, "showsound", _("Debug info about sounds")));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeXonoticCommandButton(_("Apply immediately"), '0 0 0', "snd_restart; snd_attenuation_method_$menu_snd_attenuation_method; sendcvar cl_hitsound; sendcvar cl_autotaunt; sendcvar cl_voice_directional; sendcvar cl_voice_directional_taunt_attenuation", COMMANDBUTTON_APPLY));
}
#endif
