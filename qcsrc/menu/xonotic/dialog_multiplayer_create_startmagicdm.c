#ifdef INTERFACE
CLASS(XonoticStartmagicdmDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticStartmagicdmDialog, fill, void(entity))
	METHOD(XonoticStartmagicdmDialog, showNotify, void(entity))
	METHOD(XonoticStartmagicdmDialog, close, void(entity))
	ATTRIB(XonoticStartmagicdmDialog, title, string, _("Start spells"))
	ATTRIB(XonoticStartmagicdmDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticStartmagicdmDialog, intendedWidth, float, 0.9)
	ATTRIB(XonoticStartmagicdmDialog, rows, float, 33)
	ATTRIB(XonoticStartmagicdmDialog, columns, float, 4)
	ATTRIB(XonoticStartmagicdmDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticStartmagicdmDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticStartmagicdmDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticStartmagicdmDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 0.333, e = makeXonoticTextLabel(0, _("Start Mana:")));
			//e.colorL = '0.1 0.0 0.5';
		me.TD(me, 1, 1.0, makeXonoticSlider(0, 2000, 20, "g_balance_mana_start"));
		me.TD(me, 1, 0.333, e = makeXonoticTextLabel(0, _("Mana Stable:")));
			//e.colorL = '0.1 0.0 0.5';
		me.TD(me, 1, 1.0, makeXonoticSlider(0, 5000, 20, "g_balance_mana_rotstable"));
		me.TD(me, 1, 0.333, e = makeXonoticTextLabel(0, _("Max Mana:")));
			//e.colorL = '0.1 0.0 0.5';
		me.TD(me, 1, 1.0, makeXonoticSlider(0, 5000, 1, "g_balance_mana_limit"));	
	
	me.TR(me);
	me.TD(me, 1, 0.5, makeXonoticTextLabel(0, _("Total Override")));
		me.TD(me, 1, 1.5, makeXonoticSlider(0, 2, 1, "g_start_weapon_teamoverrides"));
	/////
		me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _("Experience Curve:")));
		me.TD(me, 1, 1.5, e = makeXonoticTextSlider("g_spelllvlalgo"));
			e.addValue(e, ZCTX(_("TRGT^Lin+ExpXXX")), "0");
			e.addValue(e, ZCTX(_("TRGT^Linear")), "1");
			e.addValue(e, ZCTX(_("TRGT^LinearX")), "2");
			e.addValue(e, ZCTX(_("TRGT^Curve")), "3");
			e.addValue(e, ZCTX(_("TRGT^CurveX")), "4");
			e.addValue(e, ZCTX(_("TRGT^Lin+Expnt")), "5");
			e.addValue(e, ZCTX(_("TRGT^Lin+ExpntX")), "6");
			e.addValue(e, ZCTX(_("TRGT^Lin+ExpntXX")), "7");
			e.addValue(e, ZCTX(_("TRGT^*Algo Rvrsng Lin+EpntX*")), "8");
			e.addValue(e, ZCTX(_("TRGT^Nethack")), "9");
			e.addValue(e, ZCTX(_("TRGT^NethackX")), "10");
			e.configureXonoticTextSliderValues(e);
	/////
	
	me.TR(me);
//Team1
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("General:")));

	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Agency")));
		e.colorL = '0.5 0.2 0.11';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_agency"));
		e.colorL = '0.1 0.1 1.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Death")));
		e.colorL = '0.1 0.1 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_death"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	

	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Drainlife")));
		e.colorL = '0.5 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_drainlife"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Confer")));
		e.colorL = '0.5 0.5 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_confer"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Iceball")));
		e.colorL = '0.1 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_iceball"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Icestar")));
		e.colorL = '0.1 0.3 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_icestar"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Firebolt")));
		e.colorL = '0.5 0.17 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_firebolt"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Fireball")));
		e.colorL = '0.5 0.1 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_fireball"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Firebeam")));
		e.colorL = '0.5 0.14 0.11';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_firebeam"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("FireWall")));
		e.colorL = '0.5 0.12 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_firewall"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Flameburst")));
		e.colorL = '0.5 0.12 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_flameburst"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Frostbeam")));
		e.colorL = '0.1 0.5 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_frostbeam"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("HolyBolt")));
		e.colorL = '1.0 1.0 1.0';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_holybolt"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Lightining")));
		e.colorL = '0.1 0.2 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_lightining"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MagicMissile")));
		e.colorL = '0.38 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_magicmissile"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MonsterToMonolith")));
		e.colorL = '0.4 0.38 0.38';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_monstertomonolith"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MonsterToMouse")));
		e.colorL = '0.4 0.38 0.38';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_monstertomouse"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Meteor")));
		e.colorL = '0.3 0.1 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_meteor"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MeteorShower")));
		e.colorL = '0.3 0.125 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_meteorshower"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Mimic")));
		e.colorL = '0.2 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_mimic"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Paralyse")));
		e.colorL = '0.1 0.5 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_paralyse"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("RingOfFire")));
		e.colorL = '0.5 0.15 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_ringoffire"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("StoneCurse")));
		e.colorL = '0.3 0.3 0.3';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_stonecurse"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("LightiningStrike")));
		e.colorL = '0.1 0.2 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_lightiningstrike"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("HolyWord")));
		e.colorL = '1.0 1.0 1.0';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_holyword"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("StoneRain")));
		e.colorL = '0.4 0.3 0.3';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_stonerain"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("ManaShield")));
		e.colorL = '0.48 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_manashield"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Cancellation")));
		e.colorL = '0.2 0.2 0.2';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_cancellation"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MagicBullets")));
		e.colorL = '0.38 0.15 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_magicbullets"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("CastFromLife")));
		e.colorL = '0.5 0.0 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_castfromlife"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("PhantasmalBarrier")));
		e.colorL = '0.38 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_phantasmalbarrier"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("RaiseUndead")));
		e.colorL = '0.4 0.38 0.38';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_raiseundead"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("ScepterOfFlame")));
		e.colorL = '0.5 0.14 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_scepterofflame"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Explosion")));
		e.colorL = '0.5 0.22 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_explosion"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Timesink")));
		e.colorL = '0.38 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_timesink"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Grace")));
		e.colorL = '1.0 1.0 1.0';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_grace"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2); 
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("VampyricConduit")));
		e.colorL = '0.5 0.0 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_vampyricconduit"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Extinguish")));
		e.colorL = '0.1 0.1 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_extinguish"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2); 
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Clairvoyance")));
		e.colorL = '0.5 0.1 0.3';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_clairvoyance"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("DarkRitual")));
		e.colorL = '0.1 0.1 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_darkritual"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Heal")));
		e.colorL = '1.0 1.0 1.0';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_heal"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Repair")));
		e.colorL = '0.38 0.1 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_repair"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Inferno")));
		e.colorL = '0.5 0.135 0.11';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_inferno"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("AcerviLux")));
		e.colorL = '1.0 1.0 1.0';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_acervilux"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("ChainLightining")));
		e.colorL = '0.1 0.2 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_chainlightining"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("BallLightining")));
		e.colorL = '0.1 0.2 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_balllightining"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("ChargedBolt")));
		e.colorL = '0.1 0.2 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_chargedbolt"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("LightiningBurst")));
		e.colorL = '0.1 0.2 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_lightiningburst"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("LightiningWall")));
		e.colorL = '0.1 0.2 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_lightiningwall"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("HolyLight")));
		e.colorL = '1.0 1.0 1.0';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_holylight"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("AquaCaelestis")));
		e.colorL = '0.5 0.5 0.7';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_aquacaelestis"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Nivosus")));
		e.colorL = '0.5 0.5 0.5';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_nivosus"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Rosa")));
		e.colorL = '0.8 0.0 0.25';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_rosa"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("CorvusPenna")));
		e.colorL = '0.15 0.15 0.15';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_corvuspenna"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Plumosus")));
		e.colorL = '0.8 0.8 0.8';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_plumosus"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MagmaSphere")));
		e.colorL = '0.5 0.1 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_magmasphere"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("FireCentury")));
		e.colorL = '0.5 0.23 0.1';
	me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 20, 1, "g_start_spell_firecentury"));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);


	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticStartmagicdmDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticStartmagicdmDialog).close(me);
}
#endif
