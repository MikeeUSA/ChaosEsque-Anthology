#ifdef INTERFACE
CLASS(XonoticStartmagicDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticStartmagicDialog, fill, void(entity))
	METHOD(XonoticStartmagicDialog, showNotify, void(entity))
	METHOD(XonoticStartmagicDialog, close, void(entity))
	ATTRIB(XonoticStartmagicDialog, title, string, _("Team spells"))
	ATTRIB(XonoticStartmagicDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticStartmagicDialog, intendedWidth, float, 0.9)
	ATTRIB(XonoticStartmagicDialog, rows, float, 33)
	ATTRIB(XonoticStartmagicDialog, columns, float, 4)
	ATTRIB(XonoticStartmagicDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticStartmagicDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticStartmagicDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticStartmagicDialog_fill(entity me)
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
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Team 1:")));
	//Adding 0.5 0.0 0.0 to colors //Red tint
	me.TR(me); 
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Agency")));
		e.colorL = '1.0 0.2 0.11';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_agency"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Death")));
		e.colorL = '0.6 0.1 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_death"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Drainlife")));
		e.colorL = '1.0 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_drainlife"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Confer")));
		e.colorL = '1.0 0.5 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_confer"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Iceball")));
		e.colorL = '0.6 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_iceball"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Icestar")));
		e.colorL = '0.6 0.3 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_icestar"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);//
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebolt")));
		e.colorL = '1.0 0.17 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_firebolt"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Fireball")));
		e.colorL = '1.0 0.1 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_fireball"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebeam")));
		e.colorL = '1.0 0.14 0.11';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_firebeam"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireWall")));
		e.colorL = '1.0 0.12 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_firewall"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Flameburst")));
		e.colorL = '1.0 0.12 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_flameburst"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Frostbeam")));
		e.colorL = '0.6 0.5 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_frostbeam"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyBolt")));
		e.colorL = '1.0 0.7 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_holybolt"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Lightining")));
		e.colorL = '0.6 0.2 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_lightining"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicMissile")));
		e.colorL = '0.88 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_magicmissile"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMonolith")));
		e.colorL = '0.9 0.38 0.38';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_monstertomonolith"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMouse")));
		e.colorL = '0.9 0.38 0.38';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_monstertomouse"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Meteor")));
		e.colorL = '0.8 0.1 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_meteor"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MeteorShower")));
		e.colorL = '0.8 0.125 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_meteorshower"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Mimic")));
		e.colorL = '0.7 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_mimic"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Paralyse")));
		e.colorL = '0.6 0.5 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_paralyse"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RingOfFire")));
		e.colorL = '1.0 0.15 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_ringoffire"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneCurse")));
		e.colorL = '0.8 0.3 0.3';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_stonecurse"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningStrike")));
		e.colorL = '0.6 0.2 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_lightiningstrike"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyWord")));
		e.colorL = '1.0 0.7 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_holyword"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneRain")));
		e.colorL = '0.9 0.3 0.3';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_stonerain"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ManaShield")));
		e.colorL = '0.98 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_manashield"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Cancellation")));
		e.colorL = '0.7 0.2 0.2';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_cancellation"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicBullets")));
		e.colorL = '0.88 0.15 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_magicbullets"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CastFromLife")));
		e.colorL = '1.0 0.1 0.2';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_castfromlife"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("PhantasmalBarrier")));
		e.colorL = '0.88 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_phantasmalbarrier"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RaiseUndead")));
		e.colorL = '0.9 0.38 0.38';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_raiseundead"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ScepterOfFlame")));
		e.colorL = '1.0 0.14 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_scepterofflame"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Explosion")));
		e.colorL = '1.0 0.22 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_explosion"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Timesink")));
		e.colorL = '0.88 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_timesink"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Grace")));
		e.colorL = '1.0 0.7 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_grace"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("VampyricConduit")));
		e.colorL = '1.0 0.1 0.2';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_vampyricconduit"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Extinguish")));
		e.colorL = '0.6 0.1 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_extinguish"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Clairvoyance")));
		e.colorL = '0.98 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_clairvoyance"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("DarkRitual")));
		e.colorL = '0.6 0.1 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_darkritual"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Heal")));
		e.colorL = '1.0 0.7 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_heal"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Repair")));
		e.colorL = '0.88 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_repair"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Inferno")));
		e.colorL = '1.0 0.14 0.11';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_inferno"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AcerviLux")));
		e.colorL = '1.0 0.7 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_acervilux"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChainLightining")));
		e.colorL = '0.6 0.2 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_chainlightining"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BallLightining")));
		e.colorL = '0.6 0.2 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_balllightining"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChargedBolt")));
		e.colorL = '0.6 0.2 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_chargedbolt"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningBurst")));
		e.colorL = '0.6 0.2 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_lightiningburst"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningWall")));
		e.colorL = '0.6 0.2 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_lightiningwall"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyLight")));
		e.colorL = '1.0 0.7 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_holylight"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AquaCaelestis")));
		e.colorL = '0.75 0.25 0.35';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_aquacaelestis"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Nivosus")));
		e.colorL = '0.75 0.25 0.25';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_nivosus"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Rosa")));
		e.colorL = '0.75 0.1 0.125';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_rosa"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CorvusPenna")));
		e.colorL = '0.525 0.125 0.125';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_corvuspenna"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Plumosus")));
		e.colorL = '0.5 0.25 0.25';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_plumosus"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagmaSphere")));
		e.colorL = '1.0 0.1 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_magmasphere"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireCentury")));
		e.colorL = '1.0 0.12 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team1_firecentury"));
		e.colorL = '0.5 0.1 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
me.gotoRC(me, 2, 1); me.setFirstColumn(me, me.currentColumn);	
//Team2
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Team 2:")));
	//Adding 0.0 0.0 0.5 to colors
	me.TR(me);
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Agency")));
		e.colorL = '0.5 0.2 0.61';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_agency"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Death")));
		e.colorL = '0.1 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_death"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Drainlife")));
		e.colorL = '0.5 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_drainlife"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Confer")));
		e.colorL = '0.5 0.5 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_confer"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Iceball")));
		e.colorL = '0.1 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_iceball"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Icestar")));
		e.colorL = '0.1 0.3 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_icestar"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebolt")));
		e.colorL = '0.5 0.17 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_firebolt"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Fireball")));
		e.colorL = '0.5 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_fireball"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebeam")));
		e.colorL = '0.5 0.14 0.61';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_firebeam"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireWall")));
		e.colorL = '0.5 0.12 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_firewall"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Flameburst")));
		e.colorL = '0.5 0.12 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_flameburst"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Frostbeam")));
		e.colorL = '0.1 0.5 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_frostbeam"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyBolt")));
		e.colorL = '0.7 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_holybolt"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Lightining")));
		e.colorL = '0.1 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_lightining"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicMissile")));
		e.colorL = '0.38 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_magicmissile"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMonolith")));
		e.colorL = '0.4 0.38 0.88';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_monstertomonolith"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMouse")));
		e.colorL = '0.4 0.38 0.88';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_monstertomouse"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Meteor")));
		e.colorL = '0.3 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_meteor"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MeteorShower")));
		e.colorL = '0.3 0.125 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_meteorshower"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Mimic")));
		e.colorL = '0.2 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_mimic"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Paralyse")));
		e.colorL = '0.1 0.5 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_paralyse"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RingOfFire")));
		e.colorL = '0.5 0.15 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_ringoffire"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneCurse")));
		e.colorL = '0.3 0.3 0.8';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_stonecurse"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningStrike")));
		e.colorL = '0.1 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_lightiningstrike"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyWord")));
		e.colorL = '0.7 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_holyword"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneRain")));
		e.colorL = '0.4 0.3 0.8';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_stonerain"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ManaShield")));
		e.colorL = '0.48 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_manashield"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Cancellation")));
		e.colorL = '0.2 0.2 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_cancellation"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicBullets")));
		e.colorL = '0.38 0.15 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_magicbullets"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CastFromLife")));
		e.colorL = '0.5 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_castfromlife"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("PhantasmalBarrier")));
		e.colorL = '0.38 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_phantasmalbarrier"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RaiseUndead")));
		e.colorL = '0.4 0.38 0.88';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_raiseundead"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ScepterOfFlame")));
		e.colorL = '0.5 0.14 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_scepterofflame"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Explosion")));
		e.colorL = '0.5 0.22 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_explosion"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Timesink")));
		e.colorL = '0.38 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_timesink"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Grace")));
		e.colorL = '0.7 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_grace"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("VampyricConduit")));
		e.colorL = '0.5 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_vampyricconduit"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Extinguish")));
		e.colorL = '0.1 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_extinguish"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Clairvoyance")));
		e.colorL = '0.48 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_clairvoyance"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("DarkRitual")));
		e.colorL = '0.1 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_darkritual"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Heal")));
		e.colorL = '0.7 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_heal"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Repair")));
		e.colorL = '0.38 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_repair"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
		
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Inferno")));
		e.colorL = '0.5 0.14 0.61';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_inferno"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AcerviLux")));
		e.colorL = '0.7 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_acervilux"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChainLightining")));
		e.colorL = '0.1 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_chainlightining"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BallLightining")));
		e.colorL = '0.1 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_balllightining"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChargedBolt")));
		e.colorL = '0.1 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_chargedbolt"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningBurst")));
		e.colorL = '0.1 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_lightiningburst"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningWall")));
		e.colorL = '0.1 0.1 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_lightiningwall"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyLight")));
		e.colorL = '0.7 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_holylight"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AquaCaelestis")));
		e.colorL = '0.25 0.25 0.85';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_aquacaelestis"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Nivosus")));
		e.colorL = '0.25 0.25 0.75';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_nivosus"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Rosa")));
		e.colorL = '0.25 0.1 0.525';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_rosa"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CorvusPenna")));
		e.colorL = '0.125 0.125 0.525';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_corvuspenna"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Plumosus")));
		e.colorL = '0.25 0.25 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_plumosus"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagmaSphere")));
		e.colorL = '0.5 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_magmasphere"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireCentury")));
		e.colorL = '0.5 0.12 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team2_firecentury"));
		e.colorL = '0.1 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	

	
	

me.gotoRC(me, 2, 2); me.setFirstColumn(me, me.currentColumn);
//Team3
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Team 3:")));
	//Adding 0.5 0.5 0 to colors
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Agency")));
		e.colorL = '1.0 0.7 0.11';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_agency"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Death")));
		e.colorL = '0.6 0.6 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_death"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Drainlife")));
		e.colorL = '1.0 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_drainlife"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Confer")));
		e.colorL = '1.0 1.0 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_confer"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Iceball")));
		e.colorL = '0.6 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_iceball"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Icestar")));
		e.colorL = '0.6 0.8 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_icestar"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebolt")));
		e.colorL = '1.0 0.67 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_firebolt"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Fireball")));
		e.colorL = '1.0 0.6 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_fireball"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebeam")));
		e.colorL = '1.0 0.64 0.11';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_firebeam"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireWall")));
		e.colorL = '1.0 0.62 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_firewall"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Flameburst")));
		e.colorL = '1.0 0.62 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_flameburst"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Frostbeam")));
		e.colorL = '0.6 1.0 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_frostbeam"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyBolt")));
		e.colorL = '1.0 1.0 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_holybolt"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Lightining")));
		e.colorL = '0.6 0.7 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_lightining"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicMissile")));
		e.colorL = '0.88 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_magicmissile"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMonolith")));
		e.colorL = '0.9 0.88 0.38';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_monstertomonolith"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMouse")));
		e.colorL = '0.9 0.88 0.38';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_monstertomouse"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Meteor")));
		e.colorL = '0.8 0.6 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_meteor"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MeteorShower")));
		e.colorL = '0.8 0.625 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_meteorshower"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Mimic")));
		e.colorL = '0.7 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_mimic"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Paralyse")));
		e.colorL = '0.6 1.0 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_paralyse"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RingOfFire")));
		e.colorL = '1.0 0.65 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_ringoffire"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneCurse")));
		e.colorL = '0.8 0.8 0.3';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_stonecurse"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningStrike")));
		e.colorL = '0.6 0.7 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_lightiningstrike"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyWord")));
		e.colorL = '1.0 1.0 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_holyword"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneRain")));
		e.colorL = '0.9 0.8 0.3';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_stonerain"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ManaShield")));
		e.colorL = '0.98 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_manashield"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Cancellation")));
		e.colorL = '0.7 0.7 0.2';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_cancellation"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicBullets")));
		e.colorL = '0.88 0.65 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_magicbullets"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CastFromLife")));
		e.colorL = '1.0 0.5 0.2';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_castfromlife"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("PhantasmalBarrier")));
		e.colorL = '0.88 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_phantasmalbarrier"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RaiseUndead")));
		e.colorL = '0.9 0.88 0.38';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_raiseundead"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ScepterOfFlame")));
		e.colorL = '1.0 0.64 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_scepterofflame"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Explosion")));
		e.colorL = '1.0 0.72 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_explosion"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Timesink")));
		e.colorL = '0.88 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_timesink"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Grace")));
		e.colorL = '1.0 1.0 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_grace"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("VampyricConduit")));
		e.colorL = '1.0 0.5 0.2';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_vampyricconduit"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Extinguish")));
		e.colorL = '0.6 0.6 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_extinguish"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Clairvoyance")));
		e.colorL = '0.98 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_clairvoyance"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("DarkRitual")));
		e.colorL = '0.6 0.6 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_darkritual"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	 
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Heal")));
		e.colorL = '1.0 1.0 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_heal"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Repair")));
		e.colorL = '0.88 0.6 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_repair"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me); 
	
			
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Inferno")));
		e.colorL = '1.0 0.64 0.11';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_inferno"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AcerviLux")));
		e.colorL = '1.0 1.0 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_acervilux"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChainLightining")));
		e.colorL = '0.6 0.7 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_chainlightining"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BallLightining")));
		e.colorL = '0.6 0.7 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_balllightining"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChargedBolt")));
		e.colorL = '0.6 0.7 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_chargedbolt"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningBurst")));
		e.colorL = '0.6 0.7 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_lightiningburst"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningWall")));
		e.colorL = '0.6 0.7 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_lightiningwall"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyLight")));
		e.colorL = '1.0 1.0 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_holylight"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AquaCaelestis")));
		e.colorL = '0.75 0.75 0.35';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_aquacaelestis"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Nivosus")));
		e.colorL = '0.75 0.75 0.25';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_nivosus"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Rosa")));
		e.colorL = '0.75 0.5 0.125';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_rosa"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CorvusPenna")));
		e.colorL = '0.525 0.525 0.125';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_corvuspenna"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Plumosus")));
		e.colorL = '0.5 0.5 0.25';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_plumosus"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagmaSphere")));
		e.colorL = '1.0 0.6 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_magmasphere"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireCentury")));
		e.colorL = '1.0 0.62 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team3_firecentury"));
		e.colorL = '0.5 0.5 0.1'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
me.gotoRC(me, 2, 3); me.setFirstColumn(me, me.currentColumn);
//Team4
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Team 4:")));
	//Adding 0.5 0.0 0.5 to colors
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Agency")));
		e.colorL = '1.0 0.2 0.61';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_agency"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Death")));
		e.colorL = '0.6 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_death"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Drainlife")));
		e.colorL = '1.0 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_drainlife"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Confer")));
		e.colorL = '1.0 0.5 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_confer"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Iceball")));
		e.colorL = '0.6 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_iceball"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Icestar")));
		e.colorL = '0.6 0.3 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_icestar"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebolt")));
		e.colorL = '1.0 0.17 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_firebolt"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Fireball")));
		e.colorL = '1.0 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_fireball"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Firebeam")));
		e.colorL = '1.0 0.14 0.61';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_firebeam"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireWall")));
		e.colorL = '1.0 0.12 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_firewall"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Flameburst")));
		e.colorL = '1.0 0.12 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_flameburst"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Frostbeam")));
		e.colorL = '0.6 0.5 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_frostbeam"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyBolt")));
		e.colorL = '1.0 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_holybolt"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Lightining")));
		e.colorL = '0.6 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_lightining"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicMissile")));
		e.colorL = '0.88 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_magicmissile"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMonolith")));
		e.colorL = '0.9 0.38 0.88';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_monstertomonolith"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MonsterToMouse")));
		e.colorL = '0.9 0.38 0.88';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_monstertomouse"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Meteor")));
		e.colorL = '0.8 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_meteor"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MeteorShower")));
		e.colorL = '0.8 0.125 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_meteorshower"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Mimic")));
		e.colorL = '0.7 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_mimic"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Paralyse")));
		e.colorL = '0.5 0.5 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_paralyse"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RingOfFire")));
		e.colorL = '1.0 0.15 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_ringoffire"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneCurse")));
		e.colorL = '0.8 0.3 0.8';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_stonecurse"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningStrike")));
		e.colorL = '0.6 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_lightiningstrike"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyWord")));
		e.colorL = '1.0 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_holyword"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("StoneRain")));
		e.colorL = '0.9 0.3 0.8';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_stonerain"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ManaShield")));
		e.colorL = '0.98 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_manashield"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Cancellation")));
		e.colorL = '0.7 0.2 0.7';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_cancellation"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagicBullets")));
		e.colorL = '0.88 0.15 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_magicbullets"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CastFromLife")));
		e.colorL = '1.0 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_castfromlife"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("PhantasmalBarrier")));
		e.colorL = '0.88 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_phantasmalbarrier"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RaiseUndead")));
		e.colorL = '0.9 0.38 0.88';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_raiseundead"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ScepterOfFlame")));
		e.colorL = '1.0 0.14 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_scepterofflame"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Explosion")));
		e.colorL = '1.0 0.22 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_explosion"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Timesink")));
		e.colorL = '0.88 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_timesink"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Grace")));
		e.colorL = '1.0 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_grace"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("VampyricConduit")));
		e.colorL = '1.0 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_vampyricconduit"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Extinguish")));
		e.colorL = '0.6 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_extinguish"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me); 
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Clairvoyance")));
		e.colorL = '0.98 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_clairvoyance"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("DarkRitual")));
		e.colorL = '0.6 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_darkritual"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Heal")));
		e.colorL = '1.0 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_heal"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Repair")));
		e.colorL = '0.88 0.1 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_repair"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Inferno")));
		e.colorL = '1.0 0.14 0.61';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_inferno"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AcerviLux")));
		e.colorL = '1.0 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_acervilux"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChainLightining")));
		e.colorL = '0.6 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_chainlightining"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BallLightining")));
		e.colorL = '0.6 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_balllightining"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("ChargedBolt")));
		e.colorL = '0.6 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_chargedbolt"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningBurst")));
		e.colorL = '0.6 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_lightiningburst"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightiningWall")));
		e.colorL = '0.6 0.2 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_lightiningwall"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HolyLight")));
		e.colorL = '1.0 0.7 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_holylight"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AquaCaelestis")));
		e.colorL = '0.75 0.25 0.85';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_aquacaelestis"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Nivosus")));
		e.colorL = '0.75 0.25 0.75';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_nivosus"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Rosa")));
		e.colorL = '0.75 0.1 0.525';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_rosa"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("CorvusPenna")));
		e.colorL = '0.525 0.125 0.525';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_corvuspenna"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	

	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Plumosus")));
		e.colorL = '0.5 0.25 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_plumosus"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MagmaSphere")));
		e.colorL = '1.0 0.1 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_magmasphere"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
	
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("FireCentury")));
		e.colorL = '1.0 0.12 0.6';
	me.TD(me, 1, 0.25, e = makeXonoticSlider(0, 20, 1, "g_start_spell_team4_firecentury"));
		e.colorL = '0.5 0.1 0.5'; e.cvarOffValue = "0";
	me.TR(me);
		
	

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticStartmagicDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticStartmagicDialog).close(me);
}
#endif
