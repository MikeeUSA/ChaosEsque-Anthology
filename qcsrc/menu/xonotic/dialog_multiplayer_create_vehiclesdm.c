#ifdef INTERFACE
CLASS(XonoticVehiclesdmDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticVehiclesdmDialog, fill, void(entity))
	METHOD(XonoticVehiclesdmDialog, showNotify, void(entity))
	METHOD(XonoticVehiclesdmDialog, close, void(entity))
	ATTRIB(XonoticVehiclesdmDialog, title, string, _("Vehicles"))
	ATTRIB(XonoticVehiclesdmDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticVehiclesdmDialog, intendedWidth, float, 0.9)
	ATTRIB(XonoticVehiclesdmDialog, rows, float, 18.5)
	ATTRIB(XonoticVehiclesdmDialog, columns, float, 4)
	ATTRIB(XonoticVehiclesdmDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticVehiclesdmDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticVehiclesdmDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticVehiclesdmDialog_fill(entity me)
{
	entity e;
	
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround", _("Random Military Vehicles")));
		
		me.TD(me, 1, 1.5, e = makeXonoticSlider(0, 50, 1, "g_spawnvehiclesaround_mil_max"));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 1.5, e = makeXonoticCommandButton(ZCTX(_("PRE^Default")), '0 0 0', "exec vehiclesamnt_default.cfg", 0));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TR(me);	
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmechs", _("M")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilbiplanes", _("B")));
				setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilmonoplanes", _("P")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilheli", _("H")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmiltechnicals", _("C")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilspiderbots", _("S")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);	
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowtanks", _("T")));
				setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_mil_atleast", _("1ea")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
	
		me.TD(me, 1, 1.5, e = makeXonoticCommandButton(ZCTX(_("PRE^WW1 v. Aorist")), '0 0 0', "exec vehiclesamnt_ww1vsenergy.cfg", 0));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TR(me);
	        me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Civilian Vehicles"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 1.1, e = makeXonoticSlider(0, 50, 1, "g_spawnvehiclesaround_civ_max"));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_civ_atleast", _("1ea")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
			
		me.TD(me, 1, 1.5, e = makeXonoticCommandButton(ZCTX(_("PRE^NONE")), '0 0 0', "exec vehiclesamnt_none.cfg", 0));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TR(me);	

	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Spiderbot"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_spiderbot_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LL48"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll48_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LL37"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll37_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LL24"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll24_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AA:LL24"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll24_aa_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RAA:LL24"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll24_raa_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("HEAT:LL24"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll24_heat_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AI:LL24"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll24_ai_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MechMax"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_mechmax_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MechBST"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_mechbst_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Raptor"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_raptor_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Bumblebee"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_bumblebee_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);

	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("R22"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_r22heli_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Blackhawk"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_blackhawk_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AeroCommander"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_aerocommander_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Technical"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_pickuptruck_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);


	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Nieuport"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_nieuport_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Fokker"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_fokker_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Sopwith"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_sopwith_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("T27"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankt27_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';

	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("IV"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankiv_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LL40"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tankll40_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LightAPC"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_lightapc_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("M::Raptor"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_mraptor_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);

	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("A7V"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_tanka7v_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Eindecker"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_eindecker_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Shundi"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.4 0.25 0.5';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_shundi_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.4 0.25 0.5';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Shenzong"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.4 0.25 0.5';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_shenzong_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		e.colorL = '0.4 0.25 0.5';
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("H125"))); setDependent(e, "g_spawnvehiclesaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_mil_h125heli_amnt")); setDependent(e, "g_spawnvehiclesaround", 1, 1);
	
	
	//Added Civ
	me.TR(me);
	me.TR(me);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Challenger"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.7 0.2 0.2';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_challenger_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Cruizer"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.15 0.15 0.15';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_cruizer_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Sportster"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.7 0.7 0.2';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_sportster_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Racer"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.7 1 1';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_racer_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	
	
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Fastcar"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_fastcar_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Speedcar"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_speedcar_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Limo"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_cruizerlimo_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Sedan"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_sedan_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	
	me.TR(me);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Yugo"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_yugo_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Pickup"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_pickuptruck_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("STruck"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_smalltruck_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("AeroC"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_aerocommander_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Sparrow"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_sparrow_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("R22"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_r22heli_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Blackhawk"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_blackhawk_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Farman"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_farman_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.253 0.25 0.165';
	
	me.TR(me);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Sub"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.7 0.35 0.2';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_submersible_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("Boat"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		e.colorL = '0.2 0.7 0.7';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_speedboat_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	me.TD(me, 1, 0.125, e = makeXonoticTextLabel(0, _("H125"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.375, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_h125heli_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	
	me.TDempty(me, 0.75); //Push to the side, like deluge gun, untill more small to fill in
	me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _("Bulldozer"))); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 1.5, e = makeXonoticSlider(0, 1, 0.025, "g_spawnvehiclesaround_civ_bulldozer_amnt")); setDependentAND(e, "g_spawnvehiclesaround", 1, 1, "g_spawnvehiclesaround_civ_max", 1, 0);
	
	
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Allow Drive-by Shootings")));
		me.TD(me, 1, 1.5, e = makeXonoticTextSlider("g_vehicles_allowdriveby"));
			e.addValue(e, _("none"), "0");
			e.addValue(e, _("cars"), "1");
			e.addValue(e, _("cars, boats"), "2");
			e.addValue(e, _("cars, boats, helis"), "3");
			e.addValue(e, _("cars, boats, helis, aeroplanes"), "4");
			e.addValue(e, _("cars, boats, helis, aeroplanes, spaceships"), "5");
			//e.addValue(e, _("cars, boats, helis, aeroplanes, spaceships, submarines"), "6");
			e.configureXonoticTextSliderValues(e);
			
		me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_vehicles_allowdriveby_pssngr", _("by Passengers")));
			setDependent(e, "g_vehicles_allowdriveby", 0.1, 10);
			
		me.TDempty(me, 0.1);
		me.TD(me, 1, 0.5, e = makeXonoticSlider(0, 2, 1, "g_vehicles_allowdriveby_drvr"));
			setDependent(e, "g_vehicles_allowdriveby", 0.1, 10);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("by Driver")));
			setDependent(e, "g_vehicles_allowdriveby", 0.1, 10);
	
	me.gotoRC(me, me.rows - 2, 2.5);
		//me.TDempty(me, 2.5);
		me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_vehicles_allowdriveby_pssngr_hudnorm", _("change hud")));
			setDependentAND(e, "g_vehicles_allowdriveby", 0.1, 10, "g_vehicles_allowdriveby_pssngr", 1, 1);
			
	
	
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticVehiclesdmDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticVehiclesdmDialog).close(me);
}
#endif
