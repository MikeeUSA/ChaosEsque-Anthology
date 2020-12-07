#ifdef REGISTER_WEAPON
REGISTER_WEAPON(UTILITOOL, w_utilitool, IT_NAILS, 1, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "multitool2", "utilitool", _("Utili-Tool"))
#else
#ifdef SVQC
.float utilitool_jammed;
.float utilitool_release;
.float utilitool_setting;
.float utilitool_setting_saved;
.float utilitool_click;
.float utilitool_nextrepair;
.float utilitool_rapidscrollpressed;
.float utilitool_rapidscrollnext;
.float utilitool_rapidscrollnobldnext;
.float utilitool_didntknowlastselection; //Didn't know last selected building
// weapon frames

void W_UtiliTool_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/shotgun_melee.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_multitool_primary_animtime, w_ready);

	entity meleetemp;
	meleetemp = spawn();
	meleetemp.realowner = self;
	meleetemp.think = multitool_primarythink;
	meleetemp.nextthink = time + autocvar_g_balance_utilitool_primary_melee_delay * W_WeaponRateFactor();
	W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_utilitool_primary_damage, autocvar_g_balance_utilitool_primary_melee_range);
}

float W_UtiliTool_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_utilitool_reload_ammo && self.clip_load < autocvar_g_balance_utilitool_sustained_ammo))
	{
		if (!self.utilitool_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
			self.utilitool_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.utilitool_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_utilitool()
{    
	weapon_defaultspawnfunc(WEP_UTILITOOL);
}

float utilitool_setting_print(entity meprint, float pmtdosounds, float pmtsetting) {
				local float myreturna;
				myreturna = 1; //Start with requirements met, if not it will be changed to 0 below
				if (meprint.multitool_setting == 1001) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: CommandPost");
				} else if (meprint.multitool_setting == 1002) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: EnergyShield");
				} else if (meprint.multitool_setting == 1003) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Shelter");
				} else if (meprint.multitool_setting == 1004) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: GlassBase");
				} else if (meprint.multitool_setting == 1005) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: MilHangar");
				} else if (meprint.multitool_setting == 1006) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: SecurityBuilding");
				} else if (meprint.multitool_setting == 1007) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: TankPad");
				} else if (meprint.multitool_setting == 1008) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Stockpile");
				} else if (meprint.multitool_setting == 1009) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: AmmoDepot");
				} else if (meprint.multitool_setting == 1010) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: OilTank");
				} else if (meprint.multitool_setting == 1011) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: EnergyTank");
				} else if (meprint.multitool_setting == 1012) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Apartments");
				} else if (meprint.multitool_setting == 1013) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Turret-FLAC");
				} else if (meprint.multitool_setting == 1014) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Turret-MLRS");
				} else if (meprint.multitool_setting == 1015) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: OilPump");
				} else if (meprint.multitool_setting == 1016) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: ChemicalPlant1");	
				} else if (meprint.multitool_setting == 1017) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: ChemicalPlant2");
				} else if (meprint.multitool_setting == 1018) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: ChemicalPlant3");
				} else if (meprint.multitool_setting == 1019) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: MunitionsFactory");
				} else if (meprint.multitool_setting == 1020) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: SentryTower");
				} else if (meprint.multitool_setting == 1021) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Furnace");
				} else if (meprint.multitool_setting == 1022) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: OfficeTower");
				} else if (meprint.multitool_setting == 1023) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: FireSupression");
				} else if (meprint.multitool_setting == 1024) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: OfficeTower2");
				} else if (meprint.multitool_setting == 1025) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: TensionWireTower");
				} else if (meprint.multitool_setting == 1026) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: OfficeTower3");
				} else if (meprint.multitool_setting == 1027) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: APCPad");
				} else if (meprint.multitool_setting == 1028) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: CoveredGarage");
				} else if (meprint.multitool_setting == 1029) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: BulldozerPad");
				} else if (meprint.multitool_setting == 1030) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Local Energy Battery");
				} else if (meprint.multitool_setting == 1031) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: EnergyCanopyShield");
				} else if (meprint.multitool_setting == 1032) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Local Oil Tank");
				} else if (meprint.multitool_setting == 1033) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Oil Distribution Control");
				} else if (meprint.multitool_setting == 1034) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Chemical Distribution Control");
				} else if (meprint.multitool_setting == 1035) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Combat-Suit Pad");
				} else if (meprint.multitool_setting == 1036) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Hammer-Forge");
				} else if (meprint.multitool_setting == 1037) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: ObservationTower");
				} else if (meprint.multitool_setting == 1038) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Turret-AutoSHLAC");
				
				} else if (meprint.multitool_setting == 1110) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense SHLAC");
				} else if (meprint.multitool_setting == 1111) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense AutoNex");
				} else if (meprint.multitool_setting == 1112) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense GRail");
				} else if (meprint.multitool_setting == 1113) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense BPCannon");
				} else if (meprint.multitool_setting == 1114) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense MHB50");
				} else if (meprint.multitool_setting == 1115) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense M134");
				} else if (meprint.multitool_setting == 1116) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense GAU19");
				} else if (meprint.multitool_setting == 1117) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense T17MM");
				} else if (meprint.multitool_setting == 1118) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Point Defense LaserCannon");
				
				} else if (meprint.multitool_setting == 1120) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable Energy Turret");	
				} else if (meprint.multitool_setting == 1121) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable GRail Turret");
				} else if (meprint.multitool_setting == 1122) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable T17mm Turret");
				} else if (meprint.multitool_setting == 1123) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable AA Turret");
				} else if (meprint.multitool_setting == 1124) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable RAA Turret");	
				} else if (meprint.multitool_setting == 1125) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable AI Turret");
				} else if (meprint.multitool_setting == 1126) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable HEAT Turret");
				} else if (meprint.multitool_setting == 1127) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Mannable Cannon Turret");
				} else if (meprint.multitool_setting == 1130) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Tower T17mm Turret");	
				} else if (meprint.multitool_setting == 1131) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Tower AA Turret");
				} else if (meprint.multitool_setting == 1501) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Greenhouse");
				} else if (meprint.multitool_setting == 1502) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Recruitment Post");
				} else if (meprint.multitool_setting == 1510) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: SolarPanel");
				} else if (meprint.multitool_setting == 1520) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Fence-Mil");
				} else if (meprint.multitool_setting == 1521) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Fence-Mil-Tower");
				} else if (meprint.multitool_setting == 1522) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Fence-Mil-Gate-Small");
				} else if (meprint.multitool_setting == 1523) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Fence-Mil-Gate-Large");
				} else if (meprint.multitool_setting == 1524) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: F-M-MovingGate");
				} else if (meprint.multitool_setting == 1530) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete");
				} else if (meprint.multitool_setting == 1531) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Tower");
				} else if (meprint.multitool_setting == 1532) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Gate-Small");
				} else if (meprint.multitool_setting == 1533) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Gate-Large");	
				} else if (meprint.multitool_setting == 1534) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Tall");
				} else if (meprint.multitool_setting == 1535) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Tall-Stairs");
				} else if (meprint.multitool_setting == 1536) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Tall-Tower");		
				} else if (meprint.multitool_setting == 1537) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Taller-Tower");
					
				} else if (meprint.multitool_setting == 1538) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Fill");
				} else if (meprint.multitool_setting == 1539) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Fill-Ramp");
				} else if (meprint.multitool_setting == 1540) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Interior");
				} else if (meprint.multitool_setting == 1541) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Interior-Door");
				} else if (meprint.multitool_setting == 1542) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Tall-Gate-Small");	
				} else if (meprint.multitool_setting == 1543) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Tall-Gate-Large");
					
				} else if (meprint.multitool_setting == 1546) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: W-C-MovingGate-Steel");
					
				} else if (meprint.multitool_setting == 1548) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Tall-Berm");
				} else if (meprint.multitool_setting == 1549) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Wall-Concrete-Berm");
					
				} else if (meprint.multitool_setting == 1550) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Obstruction-TankPyrs");
				} else if (meprint.multitool_setting == 1551) {
					myreturna = multitool_hksprint(meprint, "Utili-Tool Setting: Obstruction-TankPier");
				} else if (meprint.multitool_setting == 1630) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Foundation-Wall-Concrete");	
				} else if (meprint.multitool_setting == 1631) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Foundation-Tower-Concrete");
				} else if (meprint.multitool_setting == 1650) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Bridge-Tread-Landing");
				} else if (meprint.multitool_setting == 1651) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Bridge-Tread");
				} else if (meprint.multitool_setting == 1652) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Bridge-Shield");
				} else if (meprint.multitool_setting == 1653) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Bridge-Shield-Control");
					
				} else if (meprint.multitool_setting == 1680) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Vault-Metal");
				} else if (meprint.multitool_setting == 1681) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Vault-Metal-Vent");
					
				} else if (meprint.multitool_setting == 1686) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Vault-Concrete");
				
				} else if (meprint.multitool_setting == MTB64U_CONCRETE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_CASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete Casing");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_SCASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete SideCasing");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_PYR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete Pyramidion");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_CORNER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete Corner");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_RCORNER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete RoundCorner");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_STAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete Stairs");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_ICASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete InsideCasing");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_OS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete Octoside");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_OS2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete Octoside2");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_SSTAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete SideStairs");
				} else if (meprint.multitool_setting == MTB64U_CONCRETE_ISTAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Concrete InsideStairs");
					
				} else if (meprint.multitool_setting == MTB64U_CONCRETESQUARE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ConcreteSquare");
				} else if (meprint.multitool_setting == MTB64U_PLATFORM_8) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Platform-8");
				} else if (meprint.multitool_setting == MTB64U_PLATFORM_16) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Platform-16");
				} else if (meprint.multitool_setting == MTB64U_PLATFORM_24) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Platform-24");
				} else if (meprint.multitool_setting == MTB64U_PLATFORM_32) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Platform-32");
							
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_CASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete Casing");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_SCASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete SideCasing");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_PYR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete Pyramidion");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_CORNER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete Corner");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_RCORNER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete RoundCorner");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_STAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete Stairs");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_ICASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete InsideCasing");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_OS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete Octoside");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_OS2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete Octoside2");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_SSTAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete SideStairs");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETE_ISTAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcrete InsideStairs");
					
				} else if (meprint.multitool_setting == MTB64U_RCONCRETESQUARE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcreteSquare");
				} else if (meprint.multitool_setting == MTB64U_RCONCRETESQUARE2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ReenforcedConcreteSquare with Thin Metal Frame");
				
				} else if (meprint.multitool_setting == MTB64U_ARCHIVEBOX) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ArchiveBox");
					
				} else if (meprint.multitool_setting == MTB64U_INACT_OIL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalDrum");
				} else if (meprint.multitool_setting == MTB64U_ACT_OIL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-GasolineDrum");
				} else if (meprint.multitool_setting == MTB64U_ACT_EXPL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-DemolitionCharge");
				
				} else if (meprint.multitool_setting == MTB64U_FURN_BARRELP) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-PlasticBarrel");	
				} else if (meprint.multitool_setting == MTB64U_FURN_BARRELM) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-MetalCylinder");
						
				} else if (meprint.multitool_setting == MTB64U_FURN_CHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair");
				} else if (meprint.multitool_setting == MTB64U_FURN_CHAIR2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-Black");
				} else if (meprint.multitool_setting == MTB64U_FURN_CHAIR3) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-Minimalist");
				} else if (meprint.multitool_setting == MTB64U_FURN_CHAIR4) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-Basic");
				} else if (meprint.multitool_setting == MTB64U_FURN_CHAIR5) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-Basic2");
				} else if (meprint.multitool_setting == MTB64U_FURN_SCHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-TubeAndCushion");	
				} else if (meprint.multitool_setting == MTB64U_FURN_OMLCHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-OfficeModernLeather");	
				} else if (meprint.multitool_setting == MTB64U_FURN_OMLCHAIR2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-OfficeModernFauxLeather");	
				} else if (meprint.multitool_setting == MTB64U_FURN_MLHSKCHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-ModernLeatherHusk");	
				} else if (meprint.multitool_setting == MTB64U_FURN_TRIBECACHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-TribecaLeather");	
				} else if (meprint.multitool_setting == MTB64U_FURN_BARCELONACHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-Barcelona");	
				} else if (meprint.multitool_setting == MTB64U_FURN_STOOL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Stool");
				} else if (meprint.multitool_setting == MTB64U_FURN_CSTOOL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Stool-Cushioned");
				} else if (meprint.multitool_setting == MTB64U_FURN_RETROCHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Retro-Chair");	
				} else if (meprint.multitool_setting == MTB64U_FURN_PLSCHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Chair-PlasticSwivelOffice");
				} else if (meprint.multitool_setting == MTB64U_FURN_SCHDESKCHAIR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-School-Desk-and-Chair");
				} else if (meprint.multitool_setting == MTB64U_FURN_SCHINTGRDESK) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-School-Integrated-Desk");
				} else if (meprint.multitool_setting == MTB64U_FURN_CRATE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Crate");
				} else if (meprint.multitool_setting == MTB64U_FURN_DESK) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Desk");
				
				} else if (meprint.multitool_setting == MTB64U_FURN_MGSTDESK) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Desk-MetalTubeAndGlass");
				} else if (meprint.multitool_setting == MTB64U_FURN_MGSTDESKFLAT) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Desk-MetalTubeAndGlass-Flat");
				} else if (meprint.multitool_setting == MTB64U_FURN_MGSTDESKFULLCORNER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Desk-MetalTubeAndGlass-FullCorner");
					
				} else if (meprint.multitool_setting == MTB64U_FURN_TABLE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Table");
				} else if (meprint.multitool_setting == MTB64U_FURN_TABLELOW) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Table-Low");
				} else if (meprint.multitool_setting == MTB64U_FURN_TABLEGLASS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Table-Glass-Black");
				} else if (meprint.multitool_setting == MTB64U_FURN_RETROTABLE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Retro-Table");	
				} else if (meprint.multitool_setting == MTB64U_FURN_TABLESQUARE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Table-Square");
				} else if (meprint.multitool_setting == MTB64U_FURN_TABLECIRC) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Table-Circular");
				} else if (meprint.multitool_setting == MTB64U_FURN_TABLELONG) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Table-Long");
				
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-2");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET3) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-3");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET4) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-4");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNER1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Corner1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNER2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Corner2");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBAR1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Bar1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBARENDR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-BarEnd-Right");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBARENDL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-BarEnd-Left");
				
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOP1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOP1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Corner1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOP2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Corner2");
				
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPDEEP1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Deep-1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPDEEPSHORT1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Deep-Short-1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPSHORT1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Short-1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOPDEEP1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Deep-Corner1");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOPDEEP2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Deep-Corner2");
				} else if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPSHORTSHELVES1) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Cabinet-Basic-Top-Short-Shelves-1");
				
					
				} else if (meprint.multitool_setting == MTB64U_FURN_SHELVES) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Shelves");
					
				} else if (meprint.multitool_setting == MTB64U_FURN_FILECABINET) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-FileCabinet");
				} else if (meprint.multitool_setting == MTB64U_FURN_FUTON) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Futon");
				} else if (meprint.multitool_setting == MTB64U_FURN_BED) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Bed");
				} else if (meprint.multitool_setting == MTB64U_FURN_BED_FOAM) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Bed-Foam");
				} else if (meprint.multitool_setting == MTB64U_FURN_SERVER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Server");
				} else if (meprint.multitool_setting == MTB64U_FURN_LAMP_STREET) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-StreetLamp");
				} else if (meprint.multitool_setting == MTB64U_FURN_LAMP_STREET2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-StreetLamp2");
				} else if (meprint.multitool_setting == MTB64U_FURN_LAMP_STREET3) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-StreetLamp3");
				} else if (meprint.multitool_setting == MTB64U_FURN_LAMP_STREET4) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-StreetLamp4");
				} else if (meprint.multitool_setting == MTB64U_FURN_LAMP_STREET5) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-StreetLamp5");
				} else if (meprint.multitool_setting == MTB64U_FURN_SINK_PED) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-PedestalSink");
				} else if (meprint.multitool_setting == MTB64U_FURN_SINK_PED2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-PedestalSink2");	
				} else if (meprint.multitool_setting == MTB64U_FURN_SINK) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-GreySink");
				} else if (meprint.multitool_setting == MTB64U_FURN_SINK2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-DoubleSink");	
				} else if (meprint.multitool_setting == MTB64U_FURN_SHOWER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Shower");
				} else if (meprint.multitool_setting == MTB64U_FURN_TOILET) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-TallToilet");
				} else if (meprint.multitool_setting == MTB64U_FURN_TOILET2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Toilet");
				} else if (meprint.multitool_setting == MTB64U_FURN_TOILET3) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-ModernToilet");
				} else if (meprint.multitool_setting == MTB64U_FURN_STOVE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Stove");
				} else if (meprint.multitool_setting == MTB64U_FURN_STOVE2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-ModernStove");
				} else if (meprint.multitool_setting == MTB64U_FURN_STOVE3) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-BasicStove");
				} else if (meprint.multitool_setting == MTB64U_FURN_STOVE4) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-PropaneStove");	
				} else if (meprint.multitool_setting == MTB64U_FURN_FRIDGE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Refrigerator");
				} else if (meprint.multitool_setting == MTB64U_FURN_FRIDGE2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-ThinRefrigerator");
				} else if (meprint.multitool_setting == MTB64U_FURN_FRIDGE3) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-TrendyRefrigerator");
				} else if (meprint.multitool_setting == MTB64U_FURN_FRIDGE4) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-SmallRefrigerator");
				
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA1BR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherChair-Brown");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA3BR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherSofa-Brown");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA1B) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherChair-Black");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA3B) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherSofa-Black");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA1LW) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherChair-Creme");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA3LW) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherSofa-Creme");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA1LW2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherChair-White");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA3LW2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-LeatherSofa-White");
				
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA_FOAM) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Sofa-Foam");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA_TARTAN) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Sofa-Tartan");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA_POOFY) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Sofa-Plush");
				} else if (meprint.multitool_setting == MTB64U_FURN_SOFA_NORM) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-Sofa-Low");
				
				
				
				} else if (meprint.multitool_setting == MTB64U_FURN_COMCRATE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-ComCrate");
				} else if (meprint.multitool_setting == MTB64U_FURN_COMCRATE2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-ComCrate2");
				} else if (meprint.multitool_setting == MTB64U_FURN_MTLCRATE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Furniture-MetalCrate");
				
				} else if (meprint.multitool_setting == MTB64U_WINDOW_FUTURE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Window ( ) Colored");
				} else if (meprint.multitool_setting == MTB64U_WINDOW_FUTURE_X) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Window [X] Colored");
					
				} else if (meprint.multitool_setting == MTB64U_XBEAM_UP) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-XBeam Up");
				} else if (meprint.multitool_setting == MTB64U_XBEAM_OVER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-XBeam Over");
					
				} else if (meprint.multitool_setting == MTB64U_FLOOR_MTRUSS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-Floor Truss");
				
				} else if (meprint.multitool_setting == MTB64U_BWIRE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-BarbedWire");
				} else if (meprint.multitool_setting == MTB64U_BWIRE_X) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-BarbedWire X");
				} else if (meprint.multitool_setting == MTB64U_BWIRE_O) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-BarbedWire O");
					
				} else if (meprint.multitool_setting == MTB64U_CLAIMSTONE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-ClaimStone");
				
				} else if (meprint.multitool_setting == MTB64U_DOOR_R_PLAIN) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Door-64x64-Plain");
				} else if (meprint.multitool_setting == MTB64U_DOOR_R_PLAIN2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Door-64x64-Plain-White");
				
				} else if (meprint.multitool_setting == MTB64U_DOOR_R_STEEL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Door-64x64-Steel");
				} else if (meprint.multitool_setting == MTB64U_DOOR_R_GLASS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Door-64x64-Glass");
				} else if (meprint.multitool_setting == MTB64U_FITTEDWINDOW_STEELSLIT) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: FittedWindow-64-SteelGunLoop");	
				} else if (meprint.multitool_setting == MTB64U_FITTEDWINDOW_STEELPLATE) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: FittedWindow-64-SteelPlate");	
				} else if (meprint.multitool_setting == MTB64U_FITTEDWINDOW_CWALL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: FittedWindow-64-SolidWall-Concrete");	
				} else if (meprint.multitool_setting == MTB64U_FITTEDWINDOW_UWINDOW) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: FittedWindow-64-Glass");	
				
				} else if (meprint.multitool_setting == MTB64U_METAL) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss");
				} else if (meprint.multitool_setting == MTB64U_METAL_CASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss Casing");
				} else if (meprint.multitool_setting == MTB64U_METAL_SCASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss SideCasing");
				} else if (meprint.multitool_setting == MTB64U_METAL_PYR) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss Pyramidion");
				} else if (meprint.multitool_setting == MTB64U_METAL_CORNER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss Corner");
				} else if (meprint.multitool_setting == MTB64U_METAL_RCORNER) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss RoundCorner");
				} else if (meprint.multitool_setting == MTB64U_METAL_STAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss Stairs");
				} else if (meprint.multitool_setting == MTB64U_METAL_ICASING) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss InsideCasing");
				} else if (meprint.multitool_setting == MTB64U_METAL_OS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss Octoside");
				} else if (meprint.multitool_setting == MTB64U_METAL_OS2) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss Octoside2");
				} else if (meprint.multitool_setting == MTB64U_METAL_SSTAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss SideStairs");
				} else if (meprint.multitool_setting == MTB64U_METAL_ISTAIRS) {
					myreturna = multitool_hksprint(meprint, "Multi-Tool Setting: Block-64x64-MetalTruss InsideStairs");
					
				} else if (meprint.multitool_setting == 0) {
					sprint(meprint, "Melee\n");
				} else {
					sprint(meprint, sprintf("Multi-Tool Setting: %f\n", meprint.multitool_setting));
				}
				
				
				if (meprint.multitool_setting == MTB64U_FURN_STOVE2 || meprint.multitool_setting == MTB64U_FURN_FRIDGE3
				|| meprint.multitool_setting == MTB64U_FURN_SOFA_FOAM || meprint.multitool_setting == MTB64U_FURN_BED_FOAM
				|| meprint.multitool_setting == MTB64U_FURN_SOFA_TARTAN
				|| meprint.multitool_setting == MTB64U_FURN_SOFA_POOFY
				|| meprint.multitool_setting == MTB64U_FURN_SOFA_NORM
				|| meprint.multitool_setting == MTB64U_FURN_CSTOOL
				|| meprint.multitool_setting == MTB64U_FURN_OMLCHAIR2
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOP1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPDEEP1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPDEEPSHORT1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPSHORT1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPSHORTSHELVES1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET2 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET3 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET4 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNER1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNER2 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOP1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOP2 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOPDEEP1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOPDEEP2 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBAR1 && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBARENDR && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6))
				|| (meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBARENDL && (meprint.multitool_woodcolor == 1 || meprint.multitool_woodcolor == 5 || meprint.multitool_woodcolor == 6)) 
				|| meprint.multitool_setting == MTB64U_FURN_RETROCHAIR
				|| meprint.multitool_setting == MTB64U_FURN_PLSCHAIR
				|| meprint.multitool_setting == MTB64U_FURN_SCHDESKCHAIR
				|| meprint.multitool_setting == MTB64U_FURN_SCHINTGRDESK
				|| meprint.multitool_setting == MTB64U_FURN_RETROTABLE
				|| meprint.multitool_setting == MTB64U_FURN_SCHAIR) {
					if (meprint.multitool_roofcolor == -10) {
						sprint(meprint, sprintf("Roof Color:^x555 %f PlayerColor^7\n", meprint.multitool_roofcolor));
					} else if (meprint.multitool_roofcolor) {
						////    0:  '1.000000 1.000000 1.000000';
						////    1:  '1.000000 0.333333 0.000000';
						////    2:  '0.000000 1.000000 0.501961';
						
						////    3:  '0.000000 1.000000 0.000000';
						////    4:  '1.000000 0.000000 0.000000';
						////    5:  '0.000000 0.666667 1.000000';
						
						////    6:  '0.000000 1.000000 1.000000';
						////    7:  '0.501961 1.000000 0.000000';
						////    8:  '0.501961 0.000000 1.000000';
						
						////    9:  '1.000000 0.000000 1.000000';
						////   10:  '1.000000 0.000000 0.501961';
						////   11:  '0.000000 0.000000 1.000000';
						
						////   12:  '1.000000 1.000000 0.000000';
						////   13:  '0.000000 0.333333 1.000000';
						////   14:  '1.000000 0.666667 0.000000';
						
						if (meprint.multitool_roofcolor == 1)
							sprint(meprint, "Roof Color:^x930  1 Orange^7\n");
						else if (meprint.multitool_roofcolor == 2)
							sprint(meprint, "Roof Color:^x095  2 Cyan^7\n");
						else if (meprint.multitool_roofcolor == 3)
							sprint(meprint, "Roof Color:^x090  3 Green^7\n");
						else if (meprint.multitool_roofcolor == 4)
							sprint(meprint, "Roof Color:^x900  4 Red^7\n");
						else if (meprint.multitool_roofcolor == 5)
							sprint(meprint, "Roof Color:^x069  5 Blue^7\n");
						else if (meprint.multitool_roofcolor == 6)
							sprint(meprint, "Roof Color:^x099  6 LightBlue^7\n");
						else if (meprint.multitool_roofcolor == 7)
							sprint(meprint, "Roof Color:^x590  7 Yellow^7\n");
						else if (meprint.multitool_roofcolor == 8)
							sprint(meprint, "Roof Color:^x509  8 Purple^7\n");
						else if (meprint.multitool_roofcolor == 9)
							sprint(meprint, "Roof Color:^x909  9 Magenta^7\n");
						else if (meprint.multitool_roofcolor == 10)
							sprint(meprint, "Roof Color:^x905 10 Rose^7\n");
						else if (meprint.multitool_roofcolor == 11)
							sprint(meprint, "Roof Color:^x009 11 Blue2^7\n");
						else if (meprint.multitool_roofcolor == 12)
							sprint(meprint, "Roof Color:^x990 12 Yellow2^7\n");
						else if (meprint.multitool_roofcolor == 13)
							sprint(meprint, "Roof Color:^x039 13 Blue3^7\n");
						else if (meprint.multitool_roofcolor == 14)
							sprint(meprint, "Roof Color:^x960 14 Orange2^7\n");
						else if (meprint.multitool_roofcolor == 15)
							sprint(meprint, "Roof Color:^x444 15 ^x440C^x404Y^x044C^x400L^x004E^7\n");
						else if (meprint.multitool_roofcolor == 16)
							sprint(meprint, "Roof Color:^xFFF 16 White^7\n");
						else if (meprint.multitool_roofcolor == 17)
							sprint(meprint, "Roof Color:^x111 17 Cycle2^7\n");
						else {
							sprint(meprint, sprintf("Roof Color:^x000 %f ^7\n", meprint.multitool_roofcolor));
						
						}
					} else {
						sprint(meprint, sprintf("Roof Color:^x000 %f N^x111o^x222n^x333e^7 (Default)\n", meprint.multitool_roofcolor));
					}
				}
				
				if (meprint.multitool_setting == MTB64U_FURN_BSCKCABINET1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOP1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPDEEP1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPDEEPSHORT1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPSHORT1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETTOPSHORTSHELVES1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINET2
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINET3
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINET4
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNER1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNER2
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOP1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOP2
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOPDEEP1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETCORNERTOPDEEP2
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBAR1
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBARENDR
				|| meprint.multitool_setting == MTB64U_FURN_BSCKCABINETBARENDL)
				{
						if (meprint.multitool_woodcolor == 1)
							sprint(meprint, "Wood Color:^x222  1 Dark Metal with ^x440C^x404O^x044L^x400O^x004R^7\n");
						else if (meprint.multitool_woodcolor == 2)
							sprint(meprint, "Wood Color:^x555  2 Corrugated Metal and Wood^7\n");
						else if (meprint.multitool_woodcolor == 3)
							sprint(meprint, "Wood Color:^x777  3 Rustic Wood^7\n");
						else if (meprint.multitool_woodcolor == 4)
							sprint(meprint, "Wood Color:^x900  4 Retro Red^7\n");
						else if (meprint.multitool_woodcolor == 5)
							sprint(meprint, "Wood Color:^x0A7  5 Retro ^xAA0C^xA0AO^x0AAL^xA00O^x00AR^7\n");
						else if (meprint.multitool_woodcolor == 6)
							sprint(meprint, "Wood Color:^xFFF  6 White Plus ^xAA0C^xA0AO^x0AAL^xA00O^x00AR^7\n");
						else if (meprint.multitool_woodcolor == 7)
							sprint(meprint, "Wood Color:^x852  7 Wood and White^7\n");
						else if (meprint.multitool_woodcolor == 8)
							sprint(meprint, "Wood Color:^xA70  8 Butcher Block Top^7\n");
						else
							sprint(meprint, "Wood Color:^xFFF  0 Light^7\n");
				}
				
				if (meprint.multitool_setting == MTB64U_FURN_OMLCHAIR
				|| meprint.multitool_setting == MTB64U_FURN_MLHSKCHAIR
				|| meprint.multitool_setting == MTB64U_FURN_TRIBECACHAIR
				|| meprint.multitool_setting == MTB64U_FURN_BARCELONACHAIR)
				{
						if (meprint.multitool_woodcolor == 1)
							sprint(meprint, "Wood Color:^x531  1 Brown Leather^7\n");
						else if (meprint.multitool_woodcolor == 2)
							sprint(meprint, "Wood Color:^x000  2 Black Leather^7\n");
						else if (meprint.multitool_woodcolor == 3)
							sprint(meprint, "Wood Color:^xFFC  3 Creme Leather^7\n");
						else if (meprint.multitool_woodcolor == 4)
							sprint(meprint, "Wood Color:^x900  4 Red Leather^7\n");
						else if (meprint.multitool_woodcolor == 5)
							sprint(meprint, "Wood Color:^x009  5 Blue Leather\n");
						else if (meprint.multitool_woodcolor == 6)
							sprint(meprint, "Wood Color:^x777  6 Grey Leather\n");
						else
							sprint(meprint, "Wood Color:^xFFF  0 White Leather^7\n");
				}
				
				if (meprint.multitool_setting == MTB64U_FURN_MGSTDESK
				|| meprint.multitool_setting == MTB64U_FURN_MGSTDESKFLAT
				|| meprint.multitool_setting == MTB64U_FURN_MGSTDESKFULLCORNER)
				{
						if (meprint.multitool_woodcolor == 1)
							sprint(meprint, "Wood Color:^xFFF  1 White^7\n");
						else if (meprint.multitool_woodcolor == 2)
							sprint(meprint, "Wood Color:^x222  2 Black^7\n");
						else if (meprint.multitool_woodcolor == 3)
							sprint(meprint, "Wood Color:^x531  3 Derelict^7\n");
						else
							sprint(meprint, "Wood Color:^xAAA  0 Grey^7\n");
				}
				
				if (meprint.multitool_setting == MTB64U_FURN_SCHDESKCHAIR
				|| meprint.multitool_setting == MTB64U_FURN_SCHINTGRDESK)
				{
						if (meprint.multitool_woodcolor == 1)
							sprint(meprint, "Wood Color:^x531  1 Derelict^7\n");
						else if (meprint.multitool_woodcolor == 2)
							sprint(meprint, "Wood Color:^x421  2 Rusted^7\n");
						else
							sprint(meprint, "Wood Color:^xAAA  0 Grey^7\n");
				}
				
				if (meprint.multitool_setting == MTB64U_FURN_OMLCHAIR2)
				{
						if (meprint.multitool_woodcolor == 2)
							sprint(meprint, "Wood Color:^x333  2 Subdued^7\n");
						else if (meprint.multitool_woodcolor == 1)
							sprint(meprint, "Wood Color:^xAAA  1 Moderate^7\n");
						else
							sprint(meprint, "Wood Color:^xFFF  0 Vibrant^7\n");
				}
				
				if (pmtdosounds == 1) {
					if(pmtsetting < meprint.multitool_setting) {
						spamsound (meprint, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.50, ATTN_NORM); //Not 0.25: Heavier Firing Pin
					} else if(pmtsetting > meprint.multitool_setting) {
						spamsound (meprint, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.50, ATTN_NORM); //Not 0.25: Heavier Firing Pin
					}	
				}
				
				return myreturna;
}

float w_utilitool(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_UtiliTool_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.utilitool_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_UtiliTool_NeedManualReload())
	{
		if(autocvar_g_balance_utilitool_reload_ammo && self.clip_load < autocvar_g_balance_utilitool_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);		
		else
		{
			if((self.multitool_setting < 1001)
			|| (self.multitool_setting >= 10000 && self.multitool_setting < 20000))
				self.multitool_setting = self.utilitool_setting_saved;
				
			if(self.multitool_setting == 0) {
				if (self.BUTTON_ATCK)
				if (self.multitool_release)
				if (weapon_prepareattack(1, autocvar_g_balance_utilitool_primary_refire))
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_UtiliTool_Attack);
					self.multitool_release = 0;
					self.utilitool_rapidscrollpressed = 0;
				}
			} else {
				if (self.BUTTON_ATCK)
				if (self.multitool_jammed != 1)
				if (self.multitool_release)
				if (weapon_prepareattack(0, 0))
				{
					self.misc_bulletcounter = 0;
					
					local float qstnnobuild;
					local float umbt;
					local float oldmtbt;
					qstnnobuild = 0;
					umbt = 0;
					if (!self.multitool_blocktype) {
						if (multitool_testfor_isautoblocktypemultitool(self)) {
							umbt = 1;
							self.multitool_blocktype = 1;
						}
					}
					
					
					if (multitool_testfor_isquestionableblocktypemultitool(self)) {
							qstnnobuild = 1;
							if ((clienttype(self) == CLIENTTYPE_REAL)) {
								sprint(self, "cannot build there (questionable surface below)\n");
							}
					}
					
					
					if (qstnnobuild) {
						//Do nothing much
						w_ready();
					} else {
						//DO it!
						multitool_fire_auto();
					}
					
					if (umbt) {
						self.multitool_blocktype = oldmtbt;
					}
					
					self.multitool_release = 0;
					self.utilitool_rapidscrollpressed = 0;
				}
			}
			
			if (self.BUTTON_ATCK2)
			if (self.multitool_jammed != 1)
			if (self.multitool_release)
			//if (weapon_prepareattack(1, 0))
			{
				if(self.BUTTON_USE || self.BUTTON_HOOK) {
					multitool_setzsnap(self);
				} else if(self.BUTTON_CROUCH) {
					if (self.multitool_setting == 0)
						self.multitool_setting = MTB64ULAST;
					else if (self.multitool_setting == MTB64UFIRST)
						self.multitool_setting = 1686;
					else if (self.multitool_setting == 1686)
						self.multitool_setting = 1681;
					else if (self.multitool_setting == 1680)
						self.multitool_setting = 1653;
					else if (self.multitool_setting == 1650)
						self.multitool_setting = 1631;	
					else if (self.multitool_setting == 1630)
						self.multitool_setting = 1551;
					else if (self.multitool_setting == 1548)
						self.multitool_setting = 1546;
					else if (self.multitool_setting == 1546)
						self.multitool_setting = 1543;
					else if (self.multitool_setting == 1530)
						self.multitool_setting = 1524;
					else if (self.multitool_setting == 1520)
						self.multitool_setting = 1510;
					else if (self.multitool_setting == 1510)
						self.multitool_setting = 1502;
					else if (self.multitool_setting == 1501)
						self.multitool_setting = 1131;
					else if (self.multitool_setting == 1130)
						self.multitool_setting = 1127;
					else if (self.multitool_setting == 1120)
						self.multitool_setting = 1118;
					else if (self.multitool_setting == 1110)
						self.multitool_setting = 1038;
					else if (self.multitool_setting < 1002)
						self.multitool_setting = 0;
					else
						self.multitool_setting = self.multitool_setting - 1;
						
					if (self.multitool_setting == MTB64U_CLAIMSTONE) {
						if not(autocvar_g_balance_multitool_claimstones)
						{
							self.multitool_setting = self.multitool_setting - 1;
						}
					}
						
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
				} else {
					if (self.multitool_setting == 0)
							self.multitool_setting = 1001;
					else if (self.multitool_setting == MTB64ULAST)
							//Jump point
							self.multitool_setting = 0;
					else if (self.multitool_setting == 1038)
							//Jump point
							self.multitool_setting = 1110;
					else if (self.multitool_setting == 1118)
							//Jump point
							self.multitool_setting = 1120;
					else if (self.multitool_setting == 1127)
							//Jump point
							self.multitool_setting = 1130;
					else if (self.multitool_setting == 1131)
							//Jump point
							self.multitool_setting = 1501;
					else if (self.multitool_setting == 1502)
							//Jump point
							self.multitool_setting = 1510;
					else if (self.multitool_setting == 1510)
							//Jump point
							self.multitool_setting = 1520;
					else if (self.multitool_setting == 1524)
							//Jump point
							self.multitool_setting = 1530;
					else if (self.multitool_setting == 1543)
							//Jump point
							self.multitool_setting = 1546;
					else if (self.multitool_setting == 1546)
							//Jump point
							self.multitool_setting = 1548;
					else if (self.multitool_setting == 1551)
							//Jump point
							self.multitool_setting = 1630;
					else if (self.multitool_setting == 1631)
							//Jump point
							self.multitool_setting = 1650;
					else if (self.multitool_setting == 1653)
							//Jump point
							self.multitool_setting = 1680;
					else if (self.multitool_setting == 1681)
							//Jump point
							self.multitool_setting = 1686;
					else if (self.multitool_setting == 1686)
							//Jump point
							self.multitool_setting = MTB64UFIRST;
					//else if (self.multitool_setting > 1019 && self.multitool_setting < 1520)
					//		self.multitool_setting = 1510;
					else
						self.multitool_setting = self.multitool_setting + 1;
					
					if (self.multitool_setting == MTB64U_CLAIMSTONE) {
						if not(autocvar_g_balance_multitool_claimstones)
						{
							self.multitool_setting = 0;
						}
					}
					
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
				}
				
				self.utilitool_setting_saved = self.multitool_setting;
				
				local float mya;
				mya = utilitool_setting_print(self, 0, 0); //Always want to do this nomatter what.
				
				//Some code for rapidly scrolling through selections if secondary is pushed down for abit
				//and very rapidly through unbuildable selections for lack of requisite skill
				if (autocvar_g_balance_utilitool_rapidscroll) {
					if (self.multitool_setting == 0 || self.BUTTON_ATCK) {
						//If we're pressing the other button we stop too
						//If we're at melee we stop
						self.multitool_release = 0;
						self.utilitool_rapidscrollpressed = 0;
						self.utilitool_didntknowlastselection = 0;
					} else if (mya) {
						//If we can build it we stop... maybe
						if (self.utilitool_didntknowlastselection) {
							//We stop: Didn't know last selection, know this one though
							self.multitool_release = 0;
							//self.utilitool_rapidscrollpressed = self.utilitool_rapidscrollpressed - frametime;
							self.utilitool_rapidscrollpressed = 0;
						} else if (self.utilitool_rapidscrollpressed < autocvar_g_balance_utilitool_rapidscroll_wait) {
							self.multitool_release = 0;
							
							//Will build up the ramp down time abit (so if you momentarially let go of the button
							//you will not have to hold it down again for the wait time unless you let go
							//for longer
							self.utilitool_rapidscrollpressed = self.utilitool_rapidscrollpressed + frametime;
							
						} else if (time > self.utilitool_rapidscrollnext) {
							self.multitool_release = 1; //rapidscroll
							self.utilitool_rapidscrollnext = time + autocvar_g_balance_utilitool_rapidscroll_rate;
						} else {
							self.multitool_release = 0;
						}
						self.utilitool_didntknowlastselection = 0;
					} else {
						//Don't know how to build
						self.utilitool_didntknowlastselection = 1;
						if (self.utilitool_rapidscrollpressed < autocvar_g_balance_utilitool_rapidscroll_nobld_wait) {
							self.multitool_release = 0;
							//Will build up the ramp down time abit (so if you momentarially let go of the button
							//you will not have to hold it down again for the wait time unless you let go
							//for longer
							self.utilitool_rapidscrollpressed = self.utilitool_rapidscrollpressed + frametime;
						} else if (time > self.utilitool_rapidscrollnobldnext) {
							self.multitool_release = 1; //rapidscroll
							self.utilitool_rapidscrollnobldnext = time + autocvar_g_balance_utilitool_rapidscroll_nobld_rate;
						} else {
							self.multitool_release = 0;
						}
					}
				} else {
					//Otherwise no rapid scrolling, simple
					self.multitool_release = 0;
				}
			} else if (autocvar_g_balance_utilitool_rapidscroll && self.BUTTON_ATCK2) {
				//Didnt make it to above block, but Just pressing it...
				if not(self.BUTTON_ATCK) {
					if (self.utilitool_didntknowlastselection) {
						if (self.utilitool_rapidscrollpressed < autocvar_g_balance_utilitool_rapidscroll_nobld_wait) {
							self.multitool_release = 0;
							//Will build up the ramp down time abit (so if you momentarially let go of the button
							//you will not have to hold it down again for the wait time unless you let go
							//for longer
							self.utilitool_rapidscrollpressed = self.utilitool_rapidscrollpressed + frametime;
						} else if (time > self.utilitool_rapidscrollnobldnext) {
							self.multitool_release = 1; //rapidscroll
							self.utilitool_rapidscrollnobldnext = time + autocvar_g_balance_utilitool_rapidscroll_nobld_rate;
						} else {
							self.multitool_release = 0;
						}
					} else if (self.utilitool_rapidscrollpressed < autocvar_g_balance_utilitool_rapidscroll_wait) {
						//Do nothing
						
						//Will build up the ramp down time abit (so if you momentarially let go of the button
						//you will not have to hold it down again for the wait time unless you let go
						//for longer
						self.utilitool_rapidscrollpressed = self.utilitool_rapidscrollpressed + frametime;
					} else {
						if (time > self.utilitool_rapidscrollnext) {
							self.multitool_release = 1; //rapidscroll
							self.utilitool_rapidscrollnext = time + autocvar_g_balance_utilitool_rapidscroll_rate;
						} else {
							self.multitool_release = 0;
						}
					}
				}
			}
			
			if not(self.BUTTON_ATCK)
			if not(self.BUTTON_ATCK2) {
				self.multitool_release = 1;
				if (autocvar_g_balance_utilitool_rapidscroll && self.utilitool_rapidscrollpressed > 0) {
					//Not pressing anything, decrease the "rampup" till zero, where the wait time for rapidscroll will kick in again
					self.utilitool_rapidscrollpressed = self.utilitool_rapidscrollpressed - frametime;
				}
			}
		}
		
		if (self.multitoollight) {
			if (self.multitool_lit) {
				if ((self.watertype == CONTENT_LAVA) && self.waterlevel > 2) {
					self.multitool_lit = 0;
					if ((clienttype(self) == CLIENTTYPE_REAL)) {
						sprint(self, "Your utilitool was damaged\n");
					}
				} else if (self.multitool_setting == 0) {
					self.multitool_lit = 0;
				} else {
					self.multitoollight.multitool_lit = 1;
				}
			} else if (self.multitool_setting != 0) {
				self.multitool_lit = 1;
			}
		} else if (self.multitool_setting != 0) {
				self.multitool_lit = 1;
				multitool_spawnlight();
				//print("multilight on\n");
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_multitool2.md3");
		precache_model ("models/weapons/v_multitool2.md3");
		precache_model ("models/weapons/h_multitool2.iqm");
		precache_model ("models/misc/penant.iqm");
		
		
		//Precache Some Buildings Before They are Built
		if (autocvar_g_balance_multitoolutilitool_jitprecacheonly <= 0) {
                precache_model ("maps/buildables/building_commandpost.bsp");
		precache_model ("maps/buildables/building_shieldgen.bsp");
		precache_model ("maps/buildables/building_shieldgen_shield.bsp");
		precache_model ("maps/buildables/building_shieldgen_canopy.bsp");
		precache_model ("maps/buildables/building_shieldgen_canopy_shield.bsp");
		precache_model ("maps/buildables/building_shelter.bsp");
		precache_model ("maps/buildables/building_glassbase.bsp");
		precache_model ("maps/buildables/building_newhangar.bsp");
		precache_model ("maps/buildables/building_tankpad.bsp");
		precache_model ("maps/buildables/building_apcpad.bsp");
		precache_model ("maps/buildables/building_suitpad.bsp");
		precache_model ("maps/buildables/building_stockpile.bsp");
		precache_model ("maps/buildables/building_ammodepot.bsp");
		precache_model ("maps/buildables/building_oiltank.bsp");
		precache_model ("maps/buildables/building_oiltank_small.bsp");
		precache_model ("maps/buildables/building_oildistributionswitch.bsp");
		precache_model ("maps/buildables/building_energytank.bsp");
		precache_model ("maps/buildables/building_energytank_small.bsp");
		precache_model ("maps/buildables/building_solarpanel.bsp");
		precache_model ("maps/buildables/building_solarpanel_lock.bsp");
		precache_model ("maps/buildables/building_apartments.bsp");
		precache_model ("maps/buildables/building_officetower1.bsp");
		precache_model ("maps/buildables/building_officetower2.bsp");
		precache_model ("maps/buildables/building_officetower3.bsp");
		precache_model ("maps/buildables/building_firesuppression.bsp");
		precache_model ("maps/buildables/building_tankpier.bsp");
		precache_model ("maps/buildables/building_tur_raised.bsp");
		precache_model ("maps/buildables/building_tur_medium.bsp");
		precache_model ("maps/buildables/building_mantur_raised.bsp");
		precache_model ("maps/buildables/building_chemical1.bsp");
		precache_model ("maps/buildables/building_chemical2.bsp");
		precache_model ("maps/buildables/building_chemical3.bsp");
		precache_model ("maps/buildables/building_chemicaldistributionswitch.bsp");
		precache_model ("maps/buildables/building_factory1.bsp");
		precache_model ("maps/buildables/building_factory1_lock.bsp");
		precache_model ("maps/buildables/building_pylon.bsp");
		precache_model ("maps/buildables/building_sentry_raised.bsp");
		precache_model ("maps/buildables/building_furnace.bsp");
		precache_model ("maps/buildables/building_greenhouse.bsp");
		precache_model ("maps/buildables/building_tensionwiretower.bsp");
		precache_model ("maps/buildables/building_coveredgarage.bsp");
		precache_model ("maps/buildables/building_hammerforge.bsp");
		precache_model ("maps/buildables/building_hammerforge_lock.bsp");
		precache_model ("maps/buildables/building_observationtower1.bsp");
		precache_model ("models/pomp/pomp.zym");
		precache_model ("maps/buildables/wall_fencemil.bsp");
		precache_model ("maps/buildables/wall_fencemil_tower.bsp");
		precache_model ("maps/buildables/wall_fencemil_gate.bsp");
		precache_model ("maps/buildables/wall_fencemil_gate_large.bsp");
		precache_model ("maps/buildables/wall_concrete_interior.bsp");
		precache_model ("maps/buildables/wall_concrete_interior_door.bsp");
		precache_model ("maps/buildables/wall_concrete.bsp");
		precache_model ("maps/buildables/wall_concrete_tower.bsp");
		precache_model ("maps/buildables/wall_concrete_gate.bsp");
		precache_model ("maps/buildables/wall_concrete_gate_large.bsp");
		precache_model ("maps/buildables/wall_concrete_tall_gate.bsp");
		precache_model ("maps/buildables/wall_concrete_tall_gate_large.bsp");
		precache_model ("maps/buildables/wall_concrete_tall.bsp");
		precache_model ("maps/buildables/wall_concrete_tall_stairs.bsp");
		precache_model ("maps/buildables/wall_concrete_tall_tower.bsp");
		precache_model ("maps/buildables/wall_concrete_taller_tower.bsp");
		precache_model ("maps/buildables/wall_concrete_fill.bsp");
		precache_model ("maps/buildables/wall_concrete_fill_stairs.bsp");
		precache_model ("maps/buildables/wall_concrete_tall_berm.bsp");
		precache_model ("maps/buildables/wall_concrete_berm.bsp");
		precache_model ("maps/buildables/foundation_wall_concrete.bsp");
		precache_model ("maps/buildables/foundation_tower_concrete.bsp");
		precache_model ("maps/buildables/vault_wings_future.bsp");
		precache_model ("maps/buildables/vault_wings_concrete.bsp");
		precache_model ("maps/buildables/vault_concrete.bsp");
		precache_model ("maps/buildables/vault_future_mfloor.bsp");
		precache_model ("maps/buildables/vault_future_vent.bsp");
		precache_model ("models/misc/tanktraps_pyramid.bsp");
		
		precache_model ("maps/buildables/bridge_future.bsp");
		precache_model ("maps/buildables/bridge_future_landing.bsp");
		precache_model ("maps/buildables/bridge_future_light.bsp");
		precache_model ("maps/buildables/bridge_future_light_shield.bsp");
		precache_model ("maps/buildables/bridge_future_light_control.bsp");
		}
		
		
		//Precache Scaffolds and Rubble etc
		if (autocvar_g_balance_multitoolutilitool_jitprecacheonly <= 1) {
		precache_model ("maps/buildables/scaffold_commandpost.bsp");
		precache_model ("maps/buildables/scaffold_newhangar.bsp");
		precache_model ("maps/buildables/scaffold_shieldgen.bsp");
		precache_model ("maps/buildables/scaffold_oiltank.bsp");
		precache_model ("maps/buildables/scaffold_chemical1.bsp");
		precache_model ("maps/buildables/scaffold_chemical2.bsp");
		precache_model ("maps/buildables/scaffold_chemical3.bsp");
		precache_model ("maps/buildables/scaffold_factory1.bsp");
		precache_model ("maps/buildables/scaffold_pylon.bsp");
		precache_model ("maps/buildables/scaffold_solarpanel.bsp");
		precache_model ("maps/buildables/scaffold_apartments.bsp");
		precache_model ("maps/buildables/scaffold_tensionwiretower.bsp");
		precache_model ("maps/buildables/scaffold_wall_future_small.bsp");
		precache_model ("maps/buildables/scaffold_wall_future_small_tower.bsp");
		precache_model ("maps/buildables/scaffold_wall_future_fill.bsp");
		precache_model ("maps/buildables/scaffold_wall_future_interior.bsp");
		precache_model ("maps/buildables/scaffold_furnace.bsp");
		precache_model ("maps/buildables/scaffold_greenhouse.bsp");
		precache_model ("maps/buildables/scaffold_observationtower.bsp");
		precache_model ("maps/buildables/scaffold_foundation_wall_concrete.bsp");
		precache_model ("maps/buildables/scaffold_foundation_tower_concrete.bsp");
		precache_model ("maps/buildables/scaffold_bridge_future.bsp");
		precache_model ("maps/buildables/scaffold_bridge_future_landing.bsp");
		
		precache_model ("maps/buildables/scaffold_block_future_64.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_casing.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_casingside.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_pyramidion.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_corner.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_roundcorner.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_recessedcorner.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_stairs.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_casinginside.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_octoside.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_octoside2.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_stairs_side.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_stairs_inside.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_stairs_cheap.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_window.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_xbeam.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_xbeam_over.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_door.bsp");
		precache_model ("maps/buildables/scaffold_block_future_64_stake.bsp");
		
		precache_model ("maps/buildables/rubble_concrete_512.bsp");
		precache_model ("maps/buildables/rubble_concretedark_512.bsp");
		precache_model ("maps/buildables/rubble_concreteplain_512.bsp");
		precache_model ("maps/buildables/rubble_steelbeams_512.bsp");
		precache_model ("maps/buildables/door_down_med_steel1.bsp");
		
		precache_model ("maps/buildables/rubble_metalbar_block64.bsp");
		}
		
		precache_model ("models/marker.md3");
		precache_sound ("object/impact_stone_1.ogg");
		precache_sound ("object/impact_stone_2.ogg");
		precache_sound ("object/impact_stone_3.ogg");
		precache_sound ("object/impact_stone_4.ogg");
		precache_sound ("object/impact_stone_5.ogg");
		precache_sound ("object/impact_metal_1.ogg");
		precache_sound ("object/impact_metal_2.ogg");
		precache_sound ("object/impact_metal_3.ogg");
		precache_sound ("object/impact_metal_4.ogg");
		precache_sound ("object/impact_metal_5.ogg");
		precache_sound ("object/impact_wood_1.ogg");
		precache_sound ("object/impact_wood_2.ogg");
		precache_sound ("object/impact_wood_3.ogg");
		precache_sound ("object/impact_wood_4.ogg");
		precache_sound ("object/impact_wood_5.ogg");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		precache_sound ("misc/menu2.wav");
		precache_sound ("weapons/shotgun_melee.wav");		
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_UTILITOOL);
		self.current_ammo = ammo_nails;
		self.multitool_ammomax = 9997001;
		addstat(STAT_VEHICLESTAT_AMMO1_CURRENT,   AS_INT, vehicle_ammo1_current);
		addstat(STAT_VEHICLESTAT_AMMO1_MAX,   AS_INT, vehicle_ammo1_max);
		addstat(STAT_VEHICLESTAT_AMMO2_CURRENT,   AS_INT, vehicle_ammo2_current);
		addstat(STAT_VEHICLESTAT_AMMO2_MAX,   AS_INT, vehicle_ammo2_max);
		multitool_updateammo();
		self.multitool_update3dscaf = 1;
	}
	else if (req == WR_CHECKAMMO1)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_multitool_ammo;

		if(autocvar_g_balance_multitool_reload_ammo)		
            ammo_amount += self.(weapon_load[WEP_MULTITOOL]) >= autocvar_g_balance_multitool_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_multitool_ammo;

		if(autocvar_g_balance_multitool_reload_ammo)
            ammo_amount += self.(weapon_load[WEP_MULTITOOL]) >= autocvar_g_balance_multitool_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.multitool_lit = 0;	
	}
	else if (req == WR_RELOAD)
	{
		if (self.utilitool_jammed || self.multitool_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_utilitool_clearjam_time, w_ready);
			self.utilitool_jammed = 0;
			self.utilitool_click = 0;
			self.multitool_jammed = 0;
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "You fixed the malfunction\n");
			}
		} else {
			//W_Reload(autocvar_g_balance_multitool_ammo, autocvar_g_balance_multitool_reload_ammo, autocvar_g_balance_multitool_reload_time, "weapons/reload.wav");
			self.multitool_click = 0;
			
			if(self.BUTTON_CROUCH) {
				if (self.ammo_rockets) {
					vehicles_replenishAmmo(self, self, ammo_rockets, multitool_ammocurrentr, multitool_ammomax, self.ammo_rockets, 1);
					sound (self, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE * 0.35, ATTN_NORM);
					multitool_updateammo();
				}
			} else if(self.BUTTON_USE) {
				if (self.ammo_cells) {
					vehicles_replenishAmmo(self, self, ammo_cells, multitool_ammocurrentc, multitool_ammomax, self.ammo_cells, 1);
					sound (self, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE * 0.35, ATTN_NORM);
					multitool_updateammo();
				}
			} else if(self.BUTTON_HOOK) {
				if (self.ammo_nails) {
					vehicles_replenishAmmo(self, self, ammo_nails, multitool_ammocurrent, multitool_ammomax, self.ammo_nails, 1);
					sound (self, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE * 0.35, ATTN_NORM);
					multitool_updateammo();
				}
			} else {
				if (time > self.utilitool_nextrepair) {
					self.utilitool_nextrepair = time + 0.2;
					multitool_repairbuilding(self, autocvar_g_balance_utilitool_primary_damage * 5);
				}
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_utilitool(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent)
			if(w_random < 0.05)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.1)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.2)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/ric1.wav");
		precache_sound("weapons/ric2.wav");
		precache_sound("weapons/ric3.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
			w_deathtypestring = _("%s dematerialized by %s's Utili-Tool");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_utilitool()
//{    
//	weapon_defaultspawnfunc(WEP_UTILITOOL);
//}
