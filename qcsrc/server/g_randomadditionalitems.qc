////////////////////////////////////////////////////////////////////////////////////////////////
//randomadditionalitems, similar to above.
float autocvar_randomadditionalitems_nails_amnt;
float autocvar_randomadditionalitems_rockets_amnt;
float autocvar_randomadditionalitems_cells_amnt;
float autocvar_randomadditionalitems_shells_amnt;
float autocvar_randomadditionalitems_fuel_amnt;
float autocvar_randomadditionalitems_grenades_amnt;
float autocvar_randomadditionalitems_fragnades_amnt;
float autocvar_randomadditionalitems_flashbangs_amnt;
float autocvar_randomadditionalitems_smokenades_amnt;
float autocvar_randomadditionalitems_atmines_amnt;
float autocvar_randomadditionalitems_landmines_amnt;
float autocvar_randomadditionalitems_potion_health_amnt;
float autocvar_randomadditionalitems_potion_mana_amnt;
float autocvar_randomadditionalitems_potion_rejuv_amnt;
float autocvar_randomadditionalitems_potion_water_amnt;
float autocvar_randomadditionalitems_potion_ale_amnt;
float autocvar_randomadditionalitems_potion_vodka_amnt;
float autocvar_randomadditionalitems_potion_merlot_amnt;
float autocvar_randomadditionalitems_food_bread_amnt;
float autocvar_randomadditionalitems_food_cheeze_amnt;
float autocvar_randomadditionalitems_food_garlic_amnt;
float autocvar_randomadditionalitems_food_grapes_amnt;
float autocvar_randomadditionalitems_food_onion_amnt;
float autocvar_randomadditionalitems_food_tomato_amnt;
float autocvar_randomadditionalitems_food_turkeyleg_amnt;
float autocvar_randomadditionalitems_armor_small_amnt;
float autocvar_randomadditionalitems_armor_medium_amnt;
float autocvar_randomadditionalitems_armor_big_amnt;
float autocvar_randomadditionalitems_armor_large_amnt;
float autocvar_randomadditionalitems_health_small_amnt;
float autocvar_randomadditionalitems_health_medium_amnt;
float autocvar_randomadditionalitems_health_large_amnt;
float autocvar_randomadditionalitems_health_mega_amnt;
float autocvar_randomadditionalitems_scroll_amnt;
float autocvar_randomadditionalitems_food_bellpepper_amnt;
float autocvar_randomadditionalitems_misc_suppressor45_amnt;
float autocvar_randomadditionalitems_misc_suppressormac10_amnt;
float autocvar_randomadditionalitems_misc_suppressor9mm_amnt;
float autocvar_randomadditionalitems_misc_suppressorrifle_amnt;
float autocvar_randomadditionalitems_spellbook_amnt;
float autocvar_randomadditionalitems_skillbook_amnt;
float autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt;
float autocvar_randomadditionalitems_misc_cylinder_r1856_amnt;
float autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt;
float autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt;
float autocvar_randomadditionalitems_misc_drum_ak47_75_amnt;
float autocvar_randomadditionalitems_misc_mag_ak47_30_amnt;

float autocvar_randomadditionalitems_misc_mag_uzi_20_amnt;
float autocvar_randomadditionalitems_misc_mag_uzi_25_amnt;
float autocvar_randomadditionalitems_misc_mag_uzi_32_amnt;
float autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt;
float autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt;
float autocvar_randomadditionalitems_misc_drum_uzi_82_amnt;
float autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt;

float autocvar_randomadditionalitems_misc_mag_ak74_30_amnt;
float autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt;

float autocvar_randomadditionalitems_misc_mag_tec9_20_amnt;
float autocvar_randomadditionalitems_misc_mag_tec9_10_amnt;
float autocvar_randomadditionalitems_misc_mag_tec9_32_amnt;
float autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt;
float autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt;
float autocvar_randomadditionalitems_misc_drum_tec9_72_amnt;

float autocvar_randomadditionalitems_misc_mag_m16_20_amnt;
float autocvar_randomadditionalitems_misc_mag_m16_30_amnt;
float autocvar_randomadditionalitems_misc_betacmag_m16_amnt;

float autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt;
float autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt;

float autocvar_randomadditionalitems_misc_mag_bar_20_amnt;
float autocvar_randomadditionalitems_misc_exmag_bar_40_amnt;

float autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt;
float autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt;

float autocvar_randomadditionalitems_misc_mag_lightpistol_amnt;
float autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt;
float autocvar_randomadditionalitems_misc_drum_lightpistol_amnt;

float autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt;
float autocvar_randomadditionalitems_misc_suppressorpdw_amnt;

float autocvar_randomadditionalitems_misc_tinymag_pdw_amnt;
float autocvar_randomadditionalitems_misc_smallmag_pdw_amnt;
float autocvar_randomadditionalitems_misc_stdmag_pdw_amnt;
float autocvar_randomadditionalitems_misc_exmag40_pdw_amnt; 
float autocvar_randomadditionalitems_misc_drum_pdw_amnt;
float autocvar_randomadditionalitems_misc_betacmag_pdw_amnt;

//Percentages
float autocvar_g_randomadditionalitems_book_know_carpentry;
float autocvar_g_randomadditionalitems_book_know_mortise;
float autocvar_g_randomadditionalitems_book_know_stonemasonry;
float autocvar_g_randomadditionalitems_book_know_ironworking;
float autocvar_g_randomadditionalitems_book_know_arch;
float autocvar_g_randomadditionalitems_book_know_welding;
float autocvar_g_randomadditionalitems_book_know_concrete;

void randomadditionalitems_skillbook_biased()
{
	//Any new books add to the end.
	//Do not add in the middle or alphabetically
	//past what has allready been done initially
	//Add to the end, that's how this code works
	local float brandvar;
	///////////////////Start////////////////////////
	brandvar = random() *
	(autocvar_g_randomadditionalitems_book_know_carpentry
	+ autocvar_g_randomadditionalitems_book_know_mortise
	+ autocvar_g_randomadditionalitems_book_know_stonemasonry
	+ autocvar_g_randomadditionalitems_book_know_ironworking
	+ autocvar_g_randomadditionalitems_book_know_arch
	+ autocvar_g_randomadditionalitems_book_know_welding
	+ autocvar_g_randomadditionalitems_book_know_concrete
	);
	
	if (brandvar < autocvar_g_randomadditionalitems_book_know_carpentry) {
			spawnfunc_item_book_know_carpentry();
	} else if (brandvar < (
	autocvar_g_randomadditionalitems_book_know_carpentry
	+ autocvar_g_randomadditionalitems_book_know_mortise
	)) {
			spawnfunc_item_book_know_mortise();
	} else if (brandvar < (
	autocvar_g_randomadditionalitems_book_know_carpentry
	+ autocvar_g_randomadditionalitems_book_know_mortise
	+ autocvar_g_randomadditionalitems_book_know_stonemasonry
	)) {
			spawnfunc_item_book_know_stonemasonry();
	} else if (brandvar < (
	autocvar_g_randomadditionalitems_book_know_carpentry
	+ autocvar_g_randomadditionalitems_book_know_mortise
	+ autocvar_g_randomadditionalitems_book_know_stonemasonry
	+ autocvar_g_randomadditionalitems_book_know_ironworking
	)) {
			spawnfunc_item_book_know_ironworking();
	} else if (brandvar < (
	autocvar_g_randomadditionalitems_book_know_carpentry
	+ autocvar_g_randomadditionalitems_book_know_mortise
	+ autocvar_g_randomadditionalitems_book_know_stonemasonry
	+ autocvar_g_randomadditionalitems_book_know_ironworking
	+ autocvar_g_randomadditionalitems_book_know_arch
	)) {
			spawnfunc_item_book_know_arch();
	} else if (brandvar < (
	autocvar_g_randomadditionalitems_book_know_carpentry
	+ autocvar_g_randomadditionalitems_book_know_mortise
	+ autocvar_g_randomadditionalitems_book_know_stonemasonry
	+ autocvar_g_randomadditionalitems_book_know_ironworking
	+ autocvar_g_randomadditionalitems_book_know_arch
	+ autocvar_g_randomadditionalitems_book_know_welding
	)) {
			spawnfunc_item_book_know_welding();
	} else if (brandvar < (
	autocvar_g_randomadditionalitems_book_know_carpentry
	+ autocvar_g_randomadditionalitems_book_know_mortise
	+ autocvar_g_randomadditionalitems_book_know_stonemasonry
	+ autocvar_g_randomadditionalitems_book_know_ironworking
	+ autocvar_g_randomadditionalitems_book_know_arch
	+ autocvar_g_randomadditionalitems_book_know_welding
	+ autocvar_g_randomadditionalitems_book_know_concrete
	)) {
			spawnfunc_item_book_know_concrete();
	}
	else
	{
		//Shouldn't Get here (unless everything is set to zero)
		spawnfunc_item_book_know_carpentry();	
	}
}
			
void randomadditionalitems_chooseitem()
{
	float wrandvar;
	float randvar;
	
			self.angles_x = 0;
			self.angles_y = 0;
			self.angles_z = 0;
			
			self.absolute = 1; //Used to not do itemreplace on items (weaps) only
				
			randvar = random() *
			(autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			+ autocvar_randomadditionalitems_misc_tinymag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_smallmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_stdmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_exmag40_pdw_amnt
			+ autocvar_randomadditionalitems_misc_drum_pdw_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_pdw_amnt
			);
			
			if (randvar < autocvar_randomadditionalitems_nails_amnt) {
				spawnfunc_item_bullets();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			)) {
				spawnfunc_item_rockets();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			)) {
				spawnfunc_item_cells();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			)) {
				spawnfunc_item_shells();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			)) {
				spawnfunc_item_fuel();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			)) {
				spawnfunc_item_grenades();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			)) {
				spawnfunc_item_fragnades();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			)) {
				spawnfunc_item_flashbangs();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			)) {
				spawnfunc_item_smokenades();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			)) {
				spawnfunc_item_atmines();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			)) {
				spawnfunc_item_landmines();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			)) {
				wrandvar = random();
				if (wrandvar > 0.9) {
					spawnfunc_item_potion_health_large();
				} else if (wrandvar > 0.5) {
					spawnfunc_item_potion_health_medium();
				} else {
					spawnfunc_item_potion_health_small();
				}
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			)) {
				wrandvar = random();
				if (wrandvar > 0.9) {
					spawnfunc_item_potion_mana_large();
				} else if (wrandvar > 0.5) {
					spawnfunc_item_potion_mana_medium();
				} else {
					spawnfunc_item_potion_mana_small();
				}
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			)) {
				wrandvar = random();
				if (wrandvar > 0.9) {
					spawnfunc_item_potion_rejuv_large();
				} else if (wrandvar > 0.5) {
					spawnfunc_item_potion_rejuv_medium();
				} else {
					spawnfunc_item_potion_rejuv_small();
				}
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			)) {
				wrandvar = random();
				if (wrandvar > 0.9) {
					spawnfunc_item_potion_water_large();
				} else if (wrandvar > 0.5) {
					spawnfunc_item_potion_water_medium();
				} else {
					spawnfunc_item_potion_water_small();
				}
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			)) {
				wrandvar = random();
				if (wrandvar > 0.9) {
					spawnfunc_item_potion_ale_large();
				} else if (wrandvar > 0.5) {
					spawnfunc_item_potion_ale_medium();
				} else {
					spawnfunc_item_potion_ale_small();
				}
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			)) {
				wrandvar = random();
				if (wrandvar > 0.9) {
					spawnfunc_item_potion_vodka_large();
				} else if (wrandvar > 0.5) {
					spawnfunc_item_potion_vodka_medium();
				} else {
					spawnfunc_item_potion_vodka_small();
				}
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			)) {
				wrandvar = random();
				if (wrandvar > 0.9) {
					spawnfunc_item_potion_merlot_large();
				} else if (wrandvar > 0.5) {
					spawnfunc_item_potion_merlot_medium();
				} else {
					spawnfunc_item_potion_merlot_small();
				}
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			)) {
				spawnfunc_item_food_bread();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			)) {
				spawnfunc_item_food_cheeze();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			)) {
				spawnfunc_item_food_garlic();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			)) {
				spawnfunc_item_food_grapes();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			)) {
				spawnfunc_item_food_onion();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			)) {
				spawnfunc_item_food_tomato();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			)) {
				spawnfunc_item_food_turkeyleg();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			)) {
				spawnfunc_item_armor_small();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			)) {
				spawnfunc_item_armor_medium();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			)) {
				spawnfunc_item_armor_big();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			)) {
				spawnfunc_item_armor_large();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			)) {
				spawnfunc_item_health_small();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			)) {
				spawnfunc_item_health_medium();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			)) {
				spawnfunc_item_health_large();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			)) {
				spawnfunc_item_health_mega();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			)) {
				weapon_scrollreplacement_biased();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			)) {
				spawnfunc_item_food_bellpepper();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			)) {
				spawnfunc_item_misc_suppressor45();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			)) {
				spawnfunc_item_misc_suppressormac10();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			)) {
				spawnfunc_item_misc_suppressor9mm();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			)) {
				spawnfunc_item_misc_suppressorrifle();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			)) {
				weapon_spellbookreplacement_biased();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			)) {
				randomadditionalitems_skillbook_biased();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			)) {
				spawnfunc_item_misc_suppressor5n7mm();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			)) {
				spawnfunc_item_misc_cylinder_r1856();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			)) {
				spawnfunc_item_misc_exmag_ak47_50();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			)) {
				spawnfunc_item_misc_exmag_ak47_100();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			)) {
				spawnfunc_item_misc_drum_ak47_75();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			)) {
				spawnfunc_item_misc_mag_ak47_30();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			)) {
				spawnfunc_item_misc_mag_uzi_20();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			)) {
				spawnfunc_item_misc_mag_uzi_25();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			)) {
				spawnfunc_item_misc_mag_uzi_32();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			)) {
				spawnfunc_item_misc_exmag_uzi_40();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			)) {
				spawnfunc_item_misc_exmag_uzi_50();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			)) {
				spawnfunc_item_misc_drum_uzi_82();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			)) {
				spawnfunc_item_misc_exmag_uzi_106();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			)) {
				spawnfunc_item_misc_mag_ak74_30();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			)) {
				spawnfunc_item_misc_exmag_ak74_45();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			)) {
				spawnfunc_item_misc_mag_tec9_20();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			)) {
				spawnfunc_item_misc_mag_tec9_10();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			)) {
				spawnfunc_item_misc_mag_tec9_32();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			)) {
				spawnfunc_item_misc_exmag_tec9_36();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			)) {
				spawnfunc_item_misc_exmag_tec9_50();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			)) {
				spawnfunc_item_misc_drum_tec9_72();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			)) {
				spawnfunc_item_misc_mag_m16_20();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			)) {
				spawnfunc_item_misc_mag_m16_30();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			)) {
				spawnfunc_item_misc_betacmag_m16();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			)) {
				spawnfunc_item_misc_mag_styeraug_30();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			)) {
				spawnfunc_item_misc_exmag_styeraug_42();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			)) {
				spawnfunc_item_misc_mag_bar_20();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			)) {
				spawnfunc_item_misc_exmag_bar_40();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			)) {
				spawnfunc_item_misc_panmag_lewisgun_47();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			)) {
				spawnfunc_item_misc_panmag_lewisgun_97();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			)) {
				spawnfunc_item_misc_mag_lightpistol();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			)) {
				spawnfunc_item_misc_exmag_lightpistol();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			)) {
				spawnfunc_item_misc_drum_lightpistol();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			)) {
				spawnfunc_item_misc_betacmag_lightpistol();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			)) {
				spawnfunc_item_misc_suppressorpdw();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			+ autocvar_randomadditionalitems_misc_tinymag_pdw_amnt
			)) {
				spawnfunc_item_misc_tinymag_pdw();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			+ autocvar_randomadditionalitems_misc_tinymag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_smallmag_pdw_amnt
			)) {
				spawnfunc_item_misc_smallmag_pdw();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			+ autocvar_randomadditionalitems_misc_tinymag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_smallmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_stdmag_pdw_amnt
			)) {
				spawnfunc_item_misc_stdmag_pdw();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			+ autocvar_randomadditionalitems_misc_tinymag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_smallmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_stdmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_exmag40_pdw_amnt
			)) {
				spawnfunc_item_misc_exmag40_pdw();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			+ autocvar_randomadditionalitems_misc_tinymag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_smallmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_stdmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_exmag40_pdw_amnt
			+ autocvar_randomadditionalitems_misc_drum_pdw_amnt
			)) {
				spawnfunc_item_misc_drum_pdw();
			} else if (randvar < (
			autocvar_randomadditionalitems_nails_amnt
			+ autocvar_randomadditionalitems_rockets_amnt
			+ autocvar_randomadditionalitems_cells_amnt
			+ autocvar_randomadditionalitems_shells_amnt
			+ autocvar_randomadditionalitems_fuel_amnt
			+ autocvar_randomadditionalitems_grenades_amnt
			+ autocvar_randomadditionalitems_fragnades_amnt
			+ autocvar_randomadditionalitems_flashbangs_amnt
			+ autocvar_randomadditionalitems_smokenades_amnt
			+ autocvar_randomadditionalitems_atmines_amnt
			+ autocvar_randomadditionalitems_landmines_amnt
			+ autocvar_randomadditionalitems_potion_health_amnt
			+ autocvar_randomadditionalitems_potion_mana_amnt
			+ autocvar_randomadditionalitems_potion_rejuv_amnt
			+ autocvar_randomadditionalitems_potion_water_amnt
			+ autocvar_randomadditionalitems_potion_ale_amnt
			+ autocvar_randomadditionalitems_potion_vodka_amnt
			+ autocvar_randomadditionalitems_potion_merlot_amnt
			+ autocvar_randomadditionalitems_food_bread_amnt
			+ autocvar_randomadditionalitems_food_cheeze_amnt
			+ autocvar_randomadditionalitems_food_garlic_amnt
			+ autocvar_randomadditionalitems_food_grapes_amnt
			+ autocvar_randomadditionalitems_food_onion_amnt
			+ autocvar_randomadditionalitems_food_tomato_amnt
			+ autocvar_randomadditionalitems_food_turkeyleg_amnt
			+ autocvar_randomadditionalitems_armor_small_amnt
			+ autocvar_randomadditionalitems_armor_medium_amnt
			+ autocvar_randomadditionalitems_armor_big_amnt
			+ autocvar_randomadditionalitems_armor_large_amnt
			+ autocvar_randomadditionalitems_health_small_amnt
			+ autocvar_randomadditionalitems_health_medium_amnt
			+ autocvar_randomadditionalitems_health_large_amnt
			+ autocvar_randomadditionalitems_health_mega_amnt
			+ autocvar_randomadditionalitems_scroll_amnt
			+ autocvar_randomadditionalitems_food_bellpepper_amnt
			+ autocvar_randomadditionalitems_misc_suppressor45_amnt
			+ autocvar_randomadditionalitems_misc_suppressormac10_amnt
			+ autocvar_randomadditionalitems_misc_suppressor9mm_amnt
			+ autocvar_randomadditionalitems_misc_suppressorrifle_amnt
			+ autocvar_randomadditionalitems_spellbook_amnt
			+ autocvar_randomadditionalitems_skillbook_amnt
			+ autocvar_randomadditionalitems_misc_suppressor5n7mm_amnt
			+ autocvar_randomadditionalitems_misc_cylinder_r1856_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_50_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak47_100_amnt
			+ autocvar_randomadditionalitems_misc_drum_ak47_75_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak47_30_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_25_amnt
			+ autocvar_randomadditionalitems_misc_mag_uzi_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_40_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_uzi_82_amnt
			+ autocvar_randomadditionalitems_misc_exmag_uzi_106_amnt
			+ autocvar_randomadditionalitems_misc_mag_ak74_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_ak74_45_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_10_amnt
			+ autocvar_randomadditionalitems_misc_mag_tec9_32_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_36_amnt
			+ autocvar_randomadditionalitems_misc_exmag_tec9_50_amnt
			+ autocvar_randomadditionalitems_misc_drum_tec9_72_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_20_amnt
			+ autocvar_randomadditionalitems_misc_mag_m16_30_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_m16_amnt
			+ autocvar_randomadditionalitems_misc_mag_styeraug_30_amnt
			+ autocvar_randomadditionalitems_misc_exmag_styeraug_42_amnt
			+ autocvar_randomadditionalitems_misc_mag_bar_20_amnt
			+ autocvar_randomadditionalitems_misc_exmag_bar_40_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_47_amnt
			+ autocvar_randomadditionalitems_misc_panmag_lewisgun_97_amnt
			+ autocvar_randomadditionalitems_misc_mag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_exmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_drum_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_lightpistol_amnt
			+ autocvar_randomadditionalitems_misc_suppressorpdw_amnt
			+ autocvar_randomadditionalitems_misc_tinymag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_smallmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_stdmag_pdw_amnt
			+ autocvar_randomadditionalitems_misc_exmag40_pdw_amnt
			+ autocvar_randomadditionalitems_misc_drum_pdw_amnt
			+ autocvar_randomadditionalitems_misc_betacmag_pdw_amnt
			)) {
				spawnfunc_item_misc_betacmag_pdw();
			} else {
				//Shouldn't get here usually
				spawnfunc_item_bullets();
			}
}

void randomadditionalitems_loop(vector mymins, vector mymaxs, float mysearchfor)
{
	local float mywpn;
	entity e;
	entity myolderself;
	e = spawn();
	//e.mins = PL_MIN;
	//e.maxs = PL_MAX;
	//2qu off ground max:
	//if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 2, 1))
	if (mysearchfor != -1) {
		//Used with ZA limits (map specified etc)
		if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 100, 2, 1, mymins, mymaxs, mysearchfor))
		{
			myolderself = self;
			self = e;
			
				randomadditionalitems_chooseitem();
				
			
			self = myolderself;
			if (autocvar_g_randomadditionalitems) {
				print(vtos(e.origin)," ^4SUCCESS: we found a suitable location for random additional item. Using Za limits\n");
			} else {
				print(vtos(e.origin)," ^3SUCCESS: we found a suitable location for map suggested random additional item. Using Za limits\n");
			}
		} else {
			print("^4FAIL: no location for random additional item found. Using Za limits\n");
			remove(e);
		}
	} else {
		//Normal
		if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 2, 1, mymins, mymaxs))
		{
			myolderself = self;
			self = e;
			
				randomadditionalitems_chooseitem();
			
			self = myolderself;
			if (autocvar_g_randomadditionalitems) {
				print(vtos(e.origin)," ^4SUCCESS: we found a suitable location for random additional item\n");
			} else {
				print(vtos(e.origin)," ^3SUCCESS: we found a suitable location for map suggested random additional item\n");
			}
		} else {
			print("^4FAIL: no location for random additional item found\n");
			remove(e);
		}
	}
}

void randomadditionalitems_do (void)
{
	float i;
	local float myreturn;
	local float mysearchfor;
	local float myhavesetalimit;
	local vector mymins;
	local vector mymaxs;
	
	if (autocvar_g_randomadditionalitems) {
		//Overrides
		i = autocvar_g_randomadditionalitems;
	} else {
		i = autocvar_g_suggested_randomadditionalitems;
	}
	
	if (i > 1000) {
		print("^4RandomAdditionalItems set too high, setting to 1000\n");
		i = 1000; //Don't want to use too many ents.
	}
	
	if (autocvar_g_randomadditionalitems_ignore_za_limits) {
		mymins = world.mins;
		mymaxs = world.maxs;
		mysearchfor = -1;
	} else if ((!autocvar_g_za_usezlimits) || (!autocvar_g_za_maxz &&
	!autocvar_g_za_minz &&
	!autocvar_g_suggested_za_maxz &&
	!autocvar_g_suggested_za_minz))
	{
		mymins = world.mins;
		mymaxs = world.maxs;
		mysearchfor = -1;
	} else {
		myhavesetalimit = 0;
		mymins = world.mins;
		mymaxs = world.maxs;
			
		if (autocvar_g_za_maxz) {
			myhavesetalimit = autocvar_g_za_maxz;
			mymaxs_z = autocvar_g_za_maxz;
		} else if (autocvar_g_suggested_za_maxz) {
			myhavesetalimit = autocvar_g_suggested_za_maxz;
			mymaxs_z = autocvar_g_suggested_za_maxz;
		}
		
		if (autocvar_g_za_minz) {
			if (myhavesetalimit && myhavesetalimit <= autocvar_g_za_minz) {
				print("G_RANDOMADDITIONALITEMS NOT DOING ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				mymins_z = autocvar_g_za_minz;
			}
		} else if (autocvar_g_suggested_za_minz) {
			if (myhavesetalimit && myhavesetalimit <= autocvar_g_suggested_za_minz) {
				print("G_RANDOMADDITIONALITEMS NOT DOING SUGGESTED ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				mymins_z = autocvar_g_suggested_za_minz;
			}
		}
		
		//0 == player start, 1 == nothing, 2 == info_notnull (darkhold etc)
		if (autocvar_g_suggested_za_zlimitsearchfor == 1) {
			mysearchfor = 1;
		} else if (autocvar_g_suggested_za_zlimitsearchfor == 2) {
			mysearchfor = 2;
		} else if (autocvar_g_suggested_za_zlimitsearchfor > 2) {
			mysearchfor = 0;
		} else if (autocvar_g_suggested_za_zlimitsearchfor < 0) {
			mysearchfor = 0;	
		} else {
			mysearchfor = 0;
		}
		
	}
	
	while (i) {
		randomadditionalitems_loop(mymins, mymaxs, mysearchfor);
		i = i - 1;
	}
	remove(self);
}

void randomadditionalitems_setup(void)
{
	entity randomadditionalitemthinker;
	entity oldself;
	
	oldself = self;
	
	randomadditionalitemthinker = spawn();
	
	self = randomadditionalitemthinker;
	self.think = randomadditionalitems_do;
	
	if (autocvar_g_randomadditionalitems) {
		//Overrides
		self.nextthink = time + autocvar_g_randomadditionalitems_wait;
	} else {
		self.nextthink = time + autocvar_g_suggested_randomadditionalitems_wait;
	}
	
	//print(ftos(self.nextthink)," G_RANDOMADDITIONALITEMS NEXTTHINK\n");
	self = oldself;
}

void g_randomadditionalitems(void)
{
	if (autocvar_g_randomadditionalitems || autocvar_g_suggested_randomadditionalitems)
	{
		randomadditionalitems_setup();
	}
}
