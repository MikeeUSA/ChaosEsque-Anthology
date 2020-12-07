//The point of the code here is to remove buildings that get in the way of larger buildings by creating a 
//lattice and then checking the closest neigbors. This is spawnarray specific.

float autocvar_sv_spawnarraysctilesrectify_noprint;
float autocvar_sv_spawnarraysctilesrectify_maxiter;
float autocvar_sv_spawnarraysctilesrectify_extendedclearing;
void remove_deletesubordinatewithme_ents(entity myent);
//void spawnfunc_road_sctiles_roadwide_cross();
//float SMI_AbdBld_SelectSC_Model_ROAD_ROADWIDE_CROSS (entity e);
float SMI_AbdBld_SelectSC_Model_FILLBLOCK_1X1_CONCRETE (entity e);
float autocvar_g_spawnmiscitemsaround_abdbld_noforcedlight;
void SMI_abdbld_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);
//float SMI_AbdBld_ChooseBaseTerrainType();
void Model_FILLBLOCK_1X1_CONCRETE_extended_options (entity myent, entity mycompareent);

float removemysctilebuildingetc(entity myent, float myspawnarrayspawnflags)
{
	if (myent.isabdbld) {
			myent.spawnarray_id_membertype = -1;
			entity myoldself;
			myoldself = self;

			self = myent;
					if (myspawnarrayspawnflags & 128) {
						//No items, so we don't do below
					} else {
						remove_deletesubordinatewithme_ents(self);
					}
					self.abdbldcanburn = 0;
					self.isautoblocktypemultitool = 0;
					self.classname = "";
					self.accptcrrdbldspltr = 0;
					self.abdbldextendedsearchclass = 0;
					self.model = "null";
					self.spawnarray_id_membertype = -1; //Setting again just incase
					remove(self);
		self = myoldself;
		
		return TRUE;
	} else {
		return FALSE;
	}
}

float spwnfillentforsctiles1x1 (entity rement, float myspawnarrayspawnflags, float removeoldent, entity mycompareent) {
	entity entfill;
	entity myoldself;
	myoldself = self;
	
	entfill = spawn();

	entfill.origin = rement.origin;
	entfill.angles = rement.angles;
	entfill.v_angle = rement.v_angle; //unnecessary, yes I know. But...
	entfill.spawnflags = myspawnarrayspawnflags;
	setorigin(entfill, entfill.origin);
	
				entfill.spawnarray_id = rement.spawnarray_id;
				entfill.spawnarray_id_lvl = rement.spawnarray_id_lvl;
				entfill.spawnarray_id_row = rement.spawnarray_id_row;
				entfill.spawnarray_id_col = rement.spawnarray_id_col;
				entfill.spawnarray_id_generation = rement.spawnarray_id_generation;
				entfill.spawnarray_id_membertype = 20; //Road type, so isn't searched for.
			
	
	if (removeoldent) {	
		self = rement; //Just incase.	
		if not(removemysctilebuildingetc(rement, myspawnarrayspawnflags)) {
			remove(rement);
		}
	}
	
	self = entfill;
	//spawnfunc_road_sctiles_roadwide_cross();
	
	//Replecate spawn block here
	//SMI_AbdBld_SelectSC_Model_ROAD_ROADWIDE_CROSS(self);
	SMI_AbdBld_SelectSC_Model_FILLBLOCK_1X1_CONCRETE(self);
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	
	///////////////////////////////
	//mycompareent
		Model_FILLBLOCK_1X1_CONCRETE_extended_options(self, mycompareent);
	//
	//////////////////////////////
	
	precache_model (self.model);
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
	if (autocvar_g_spawnmiscitemsaround_abdbld_noforcedlight) {
		//If you do prefer the lightmapped effect
		spawnfunc_func_clientwallnodroptofloor();
	} else {
		spawnfunc_func_clientwallnodroptofloor_dlight(); //Exact origin for the extra things
	}
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.event_damage       = SMI_abdbld_damage;
	self.isabdbld = 1;
    	self.takedamage         = DAMAGE_YES;
	self.vehicle_health = 100000;
	//End
	
	setorigin(self, self.origin);
	
	
	self = myoldself;
	return(TRUE); //In hope to placate loop counter
}
	
float spawnarray_rectifysctileslargebuildings_do(entity mylargebuilding, float myspawnarrayspawnflags, float myremovetype)
{
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*_*spawnarray_rectifysctileslargebuildings_do\n");
	local entity f;
	local entity enrem;
	local entity nextinchain;
	local float isanextendedclearing;
	local float forcereplaceinstead;
	local float myremovedorchangedentities = 0;
	local float myfiltered = 0;
	local float myrelevant_spawnarray_id_generation;
	myrelevant_spawnarray_id_generation = mylargebuilding.spawnarray_id_generation;
	
	//Relative column and row vs our big building, 0x0 would be our building so not relevant
	//If we are a 3x3 (myremovetype 2, which is .abdbldextendedsearchclass 2) building and removing a bigbuilding beyond row or column +1 / -1 we have to do a replace instead
	//Otherwise there will be a hole where that other big building once stood (since it's centre is beyond our 3x3 footprint)
	local float rowfvsbldg, colfvsbldg;
	rowfvsbldg = 0;
	colfvsbldg = 0;
	
	f = findchainfloat(spawnarray_id, mylargebuilding.spawnarray_id); //Method 1
	//f = findfloat(world, spawnarray_id, mylargebuilding.spawnarray_id);

	while (f)
	{
		enrem = world; //reset just incase
		myfiltered = 0;
		rowfvsbldg = 0; //Relative row vs our big building
		colfvsbldg = 0; //Relative column vs our big building
		isanextendedclearing = 0;
		forcereplaceinstead = 0;
				//Some optional print statements if you want to slow things down
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Looking through spawnarray_id\n");
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("BLD ",ftos(mylargebuilding.spawnarray_id_row)," ROW\n");
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("BLD ",ftos(mylargebuilding.spawnarray_id_col)," COL\n");
		
		
		if (f != world) {  //unnecessary.. but... 
		if (f.spawnarray_id_generation == myrelevant_spawnarray_id_generation)
		{ 	//Must be same generation to be relevant, on the same grid surely
			if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("same generation\n");
			if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Looking through buildings\n");
			//2d only for now
			//Locate 3x3 grid, excluding the center (which is our bldg)
			
			//We could do assigns to rowfvsbldg and colfvsbldg in the comparisons
			//We could evaluate into rowfvsbldg and colfvsbldg and then compare.
			//But we did it this way.
			//I don't like to do assigns in comparison blocks, since it looks like a typo
			//I think it's clear what's going on here.
			//Evaluate and then compare would save some procedures... but then it's just nitpicking code. Which one can do forever
			
			if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 1))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 1)))
			{	
				rowfvsbldg = -1; //Let us inform ourselves for later
				colfvsbldg = -1; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R -C\n");
				enrem = f;
			} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 1))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col)))
			{
				rowfvsbldg = -1; //Let us inform ourselves for later
				colfvsbldg = 0; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R _C\n");
				enrem = f;
			} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 1))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 1)))
			{	
				rowfvsbldg = -1; //Let us inform ourselves for later
				colfvsbldg = 1; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R +C\n");
				enrem = f;
			} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 1)))
			{	
				rowfvsbldg = 0; //Let us inform ourselves for later
				colfvsbldg = -1; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found _R -C\n");
				enrem = f;
			//////////////////////////////////////////////////////////////////////////////////
			/// The Identity.
			//////////////////////////////////////////////////////////////////////////////////
			//} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row))
			//&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col)))
			//{
			//	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found _R _C\n");
			//	enrem = f;
			//////////////////////////////////////////////////////////////////////////////////
			//
			//////////////////////////////////////////////////////////////////////////////////
			} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 1)))
			{	
				rowfvsbldg = 0; //Let us inform ourselves for later
				colfvsbldg = 1; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found _R +C\n");
				enrem = f;
			} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 1))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 1)))
			{	
				rowfvsbldg = 1; //Let us inform ourselves for later
				colfvsbldg = -1; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R -C\n");
				enrem = f;
			} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 1))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col)))
			{	
				rowfvsbldg = 1; //Let us inform ourselves for later
				colfvsbldg = 0; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R _C\n");
				enrem = f;
			} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 1))
			&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 1)))
			{	
				rowfvsbldg = 1; //Let us inform ourselves for later
				colfvsbldg = 1; //Relative to our big building
				
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R +C\n");
				enrem = f;
			} else if (f.abdbldextendedsearchclass >= 1) {
				if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 2)))
				{
					rowfvsbldg = -2; //Let us inform ourselves for later
					colfvsbldg = -2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R2 -C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 2))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 1)))
				{
					rowfvsbldg = -2; //Let us inform ourselves for later
					colfvsbldg = -1; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R2 -C\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col)))
				{
					rowfvsbldg = -2; //Let us inform ourselves for later
					colfvsbldg = 0; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R2 _C\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 1)))
				{
					rowfvsbldg = -2; //Let us inform ourselves for later
					colfvsbldg = 1; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R2 +C\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 2)))
				{
					rowfvsbldg = -2; //Let us inform ourselves for later
					colfvsbldg = 2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R2 +C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 1))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 2)))
				{
					rowfvsbldg = -1; //Let us inform ourselves for later
					colfvsbldg = -2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R -C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 1))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 2)))
				{
					rowfvsbldg = -1; //Let us inform ourselves for later
					colfvsbldg = 2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R +C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 1))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 2)))
				{
					rowfvsbldg = 1; //Let us inform ourselves for later
					colfvsbldg = -2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R -C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 1))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 2)))
				{
					rowfvsbldg = 1; //Let us inform ourselves for later
					colfvsbldg = 2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R +C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 2)))
				{
					rowfvsbldg = 0; //Let us inform ourselves for later
					colfvsbldg = -2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found _R -C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 2)))
				{
					rowfvsbldg = 0; //Let us inform ourselves for later
					colfvsbldg = 2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found _R +C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 2)))
				{
					rowfvsbldg = 2; //Let us inform ourselves for later
					colfvsbldg = -2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R2 -C2\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 1)))
				{
				
					rowfvsbldg = 2; //Let us inform ourselves for later
					colfvsbldg = -1; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R2 -C\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col)))
				{
					rowfvsbldg = 2; //Let us inform ourselves for later
					colfvsbldg = 0; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R2 _C\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 1)))
				{
					rowfvsbldg = 2; //Let us inform ourselves for later
					colfvsbldg = 1; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R2 +C\n");
					enrem = f;
				} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 2))
				&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 2)))
				{
					rowfvsbldg = 2; //Let us inform ourselves for later
					colfvsbldg = 2; //Relative to our big building
				
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R2 +C2\n");
					enrem = f;
				} else if (autocvar_sv_spawnarraysctilesrectify_extendedclearing 
					&& ((f.abdbldextendedsearchclass >= 2) && (mylargebuilding.abdbldextendedsearchclass >= 2))) {
					//Some extents from the middle but not corners
					isanextendedclearing = 1;
					
					if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 2)))
					{
						rowfvsbldg = -3; //Let us inform ourselves for later
						colfvsbldg = -2; //Relative to our big building
				
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R3 -C2\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 3))
						&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 1)))
					{
						rowfvsbldg = -3; //Let us inform ourselves for later
						colfvsbldg = -1; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R3 -C\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col)))
					{
						rowfvsbldg = -3; //Let us inform ourselves for later
						colfvsbldg = 0; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R3 _C\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 1)))
					{
						rowfvsbldg = -3; //Let us inform ourselves for later
						colfvsbldg = 1; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R3 +C\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 2)))
					{
						rowfvsbldg = -3; //Let us inform ourselves for later
						colfvsbldg = 2; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R3 +C2\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 1))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 3)))
					{
						rowfvsbldg = -1; //Let us inform ourselves for later
						colfvsbldg = -3; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R -C3\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row - 1))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 3)))
					{
						rowfvsbldg = -1; //Let us inform ourselves for later
						colfvsbldg = 3; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found -R +C3\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 1))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 3)))
					{
						rowfvsbldg = 1; //Let us inform ourselves for later
						colfvsbldg = -3; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R -C3\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 1))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 3)))
					{
						rowfvsbldg = 1; //Let us inform ourselves for later
						colfvsbldg = 3; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R +C3\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 3)))
					{
						rowfvsbldg = 0; //Let us inform ourselves for later
						colfvsbldg = -3; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found _R -C3\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 3)))
					{
						rowfvsbldg = 0; //Let us inform ourselves for later
						colfvsbldg = 3; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found _R +C3\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 2)))
					{
						rowfvsbldg = 3; //Let us inform ourselves for later
						colfvsbldg = -2; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R3 -C2\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col - 1)))
					{
						rowfvsbldg = 3; //Let us inform ourselves for later
						colfvsbldg = -1; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R3 -C\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col)))
					{
						rowfvsbldg = 3; //Let us inform ourselves for later
						colfvsbldg = 0; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R3 _C\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 1)))
					{
						rowfvsbldg = 3; //Let us inform ourselves for later
						colfvsbldg = 1; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R3 +C\n");
						enrem = f;
					} else if ((f.spawnarray_id_row == (mylargebuilding.spawnarray_id_row + 3))
					&& (f.spawnarray_id_col == (mylargebuilding.spawnarray_id_col + 2)))
					{
						rowfvsbldg = 3; //Let us inform ourselves for later
						colfvsbldg = 2; //Relative to our big building
						
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found +R3 +C2\n");
						enrem = f;
					}
				}
				//Endeven more
			}
			//Endmore
				
		}
		}
		
		nextinchain = f.chain;
		
		if (enrem && (f == enrem)) {
			//if (!(enrem.spawnarray_id_membertype > 0)) {
			//	myfiltered = 1;
			//	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("id_membertype must be 1 or greater\n");
			//}
			
			//if (enrem.spawnarray_id_membertype == 2) { //Exclude roads
			//	myfiltered = 1;
			//	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("id_membertype must not 2 a road \n");
			//}
			
			if (enrem.isroad) {
				//Exclude roads since we don't know their size as easily
				myfiltered = 1;
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("id_membertype must not isroad \n");
			}
			
			//if (enrem.spawnarray_id_membertype == 20) {
			//	myfiltered = 1;
			//	Exclude replacements added above in this file
			//	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("id_membertype must not 20 a replacement \n");
			//}
			
			//if (enrem.spawnarray_id_membertype == -1) { //Exclude deleted
			//	myfiltered = 1;
			//	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("id_membertype must not -1 deleted \n");
			//}
			
			//if (enrem.spawnarray_id_lvl == mylargebuilding.spawnarray_id_lvl) {
			//	myfiltered = 1;
			//	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("id_membertype must not different lvl \n");
			//}
			
			//if (f != mylargebuilding) {
			//	myfiltered = 1;
			//	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("must not mylargebuilding\n");
			//}
			
			if (myremovetype == 2) {
				//my large building is a 3x3 building
				if ((rowfvsbldg >= 2)
				|| (rowfvsbldg <= -2)
				|| (colfvsbldg >= 2)
				|| (colfvsbldg <= -2)) {
					//Anything outside of the 3x3 buildings footprint should be replaced instead of removed
					//Otherwise there will be a hole where the base of the other large building was
					forcereplaceinstead = 1;
				}
			}
		}
		
		if (enrem != world && !myfiltered) {
			myremovedorchangedentities++;
			enrem.spawnarray_id_membertype = -1;
			if (myremovetype == 1 || isanextendedclearing || forcereplaceinstead) {
					if (!autocvar_sv_spawnarraysctilesrectify_noprint) {
						if (isanextendedclearing)
							print("* -- removing and replacing an enrem ExtendedClearing -- spawnarray_rectifysctileslargebuildings_do*\n");
						else
							print("* -- removing and replacing an enrem 1 -- spawnarray_rectifysctileslargebuildings_do*\n");
					}
				//here we should replace with flat/fill terrain and remove
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 7) print("^xFAAReplacing^7 ", vtos(enrem.origin), "\n");
				spwnfillentforsctiles1x1(enrem, myspawnarrayspawnflags, 1, mylargebuilding);
			} else if (myremovetype == 2) {
						if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("* -- removing an enrem 2 -- spawnarray_rectifysctileslargebuildings_do*\n");
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 7) print("^xF00Removing^7 ", vtos(enrem.origin), "\n");
				if not(removemysctilebuildingetc(enrem, myspawnarrayspawnflags)) {
					remove(enrem);
				}
			}
		}
		
		f = nextinchain; //Method 1
		//f = findfloat(f, spawnarray_id, mylargebuilding.spawnarray_id);
	}
	
	return(myremovedorchangedentities); //In hope to placate loop counter
}

void spawnarray_rectifysctileslargebuildings_run_think(); //Defined below

float spawnarray_rectifysctileslargebuildings_run (float myspawnarrayid, float myspawnarrayspawnflags, float myabdbldextendedsearchclass, entity myresumeentity, float maxiter)
{
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*spawnarray_rectifysctileslargebuildings_run*\n");
	local entity f;
	local float iter;
	local entity mycontinue;
	iter = 0;
	
	local float ahv = 0;
	
	if (myresumeentity && (myresumeentity != world)) { f = myresumeentity; ahv = 1;}
	else {
		f = findchainfloat(abdbldextendedsearchclass, myabdbldextendedsearchclass); //method1
		//f = findfloat(world, abdbldextendedsearchclass, myabdbldextendedsearchclass); //method2
	}

	while (f)
	{
		if (ahv) { if (autocvar_sv_spawnarraysctilesrectify_noprint < 6) print(ftos (myabdbldextendedsearchclass), " DOING RCFY RUN\n"); }
		
		if (f != world) { //unnecessary.. but...
		if (myspawnarrayid == f.spawnarray_id) {
			//If ever larger blds then need to make a bigger search thing
			if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("Found matchin spawnarray_id, Rectify large building\n");
			spawnarray_rectifysctileslargebuildings_do(f, myspawnarrayspawnflags, f.abdbldextendedsearchclass);
		}
		}
		
		iter++;
		if (f.chain == world) {
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 6) print(ftos (myabdbldextendedsearchclass)," WORLD IS CHAIN RCFY END\n");
			//Nothing
		} else if (maxiter && (iter > maxiter)) {
				if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("pausing rectifying");
			mycontinue = spawn();
			mycontinue.cnt = myspawnarrayid;
			mycontinue.spawnflags = myspawnarrayspawnflags;
			mycontinue.count = myabdbldextendedsearchclass;
			mycontinue.subordinate = f.chain;
			mycontinue.ammount = maxiter;
			mycontinue.think = spawnarray_rectifysctileslargebuildings_run_think;
			mycontinue.nextthink = time;
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 6) print(ftos (myabdbldextendedsearchclass)," NEXT RCFY BUNCH\n");
			return(FALSE);
			//f = world; //We won't get here, but that would be another way to escape...
		}
		f = f.chain; //method1
		//f = findfloat(f, abdbldextendedsearchclass, myabdbldextendedsearchclass); //method 2
	}
	return(TRUE);
}

void spawnarray_rectifysctileslargebuildings_run_think()
{
	//Here self.count BEGINS a 2, THEN moves to 1 when it is done.
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("continue rectifying");
	if (spawnarray_rectifysctileslargebuildings_run (self.cnt, self.spawnflags, self.count, self.subordinate, self.ammount) )
	{		 //?x? (ie: whatever self.count set to)
		if (self.count == 2) {
			/////if (!autocvar_sv_spawnarraysctilesrectify_noprint) 
			if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*****Now do second part*****\n");
			//If we are done with the first larger part (2), we now do the smaller part (1)
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 6) print("SMALLER RCFY\n");
			self.count = 1;
			spawnarray_rectifysctileslargebuildings_run (self.cnt, self.spawnflags, self.count, world, autocvar_sv_spawnarraysctilesrectify_maxiter);
		}
	}
			if (autocvar_sv_spawnarraysctilesrectify_noprint < 6) print("an RCFY removed\n");
	remove(self);
}


void spawnarray_rectifysctileslargebuildings (float myspawnarrayid, float myspawnarrayspawnflags)
{
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n");
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("**spawnarray_rectifysctileslargebuildings**\n");
	if (spawnarray_rectifysctileslargebuildings_run (myspawnarrayid, myspawnarrayspawnflags, 2, world, autocvar_sv_spawnarraysctilesrectify_maxiter)) //3x3
	{
		//If we completed that, without going over maxiter, lets do second part
		spawnarray_rectifysctileslargebuildings_run (myspawnarrayid, myspawnarrayspawnflags, 1, world, autocvar_sv_spawnarraysctilesrectify_maxiter); //2x2, but these are centerend in a 3x3 grid..really so far sorta
	}
}

void spawnarraysctilesrectifyafterdelay_think() {
	if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("**spawnarraysctilesrectifyafterdelay_think**\n");
	local entity myoldself;
	
	myoldself = self;
	
	spawnarray_rectifysctileslargebuildings(self.spawnarray_id, self.spawnflags);
	
	self = myoldself;
	remove(self);
}

void spawnarraysctilesrectifyafterdelay(float myspawnarrayid, float myspawnarrayspawnflags, entity myself, float mydelay, float myjitter) {
	 if (!autocvar_sv_spawnarraysctilesrectify_noprint) print("***spawnarraysctilesrectifyafterdelay***\n");
	 myself.spawnarray_id = myspawnarrayid;
	 myself.spawnflags = myspawnarrayspawnflags;
	 myself.think = spawnarraysctilesrectifyafterdelay_think;
	 myself.nextthink = time + mydelay + (random() * myjitter);
}

