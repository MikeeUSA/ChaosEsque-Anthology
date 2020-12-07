.float spawnarray_rows;
.float spawnarray_cols;
.float spawnarray_lvls;
.float spawnarray_row_offset;
.float spawnarray_col_offset;
.float spawnarray_lvl_offset;
.float spawnarray_lvl_addangle;
.vector spawnarray_lvl_addangles;
.float spawnarray_add2offset;
.float spawnarray_add2offset_noup;
.float spawnarray_add2offset_norow;
.float spawnarray_add2offset_nocol;
//.void() spawnarray_func; //Doing it another way
.string spawnarray_spawn;
.float spawnarray_strict;
.float spawnarray_absolute;
.float spawnarray_reversex;
.float spawnarray_reversey;
.float spawnarray_reversez;
.float spawnarray_evaleachoffset;
.float spawnarray_droptofloor;

.float spawnarray_sctilesspecial;

.float abdbld_baseheightrand_sc;
.float abdbld_baseheightrandmax_sc;
.float abdbld_baseheight_sc;

//Iterations
.float spawnarray_iter;
.float spawnarray_iter_and;
.float spawnarray_iter_skipuntil; //Add one only ever X
.float spawnarray_iter_suresetrow;
.float spawnarray_iter_suresetlvl;
.float spawnarray_iter_andobeyskip; //obeys the skips
.float spawnarray_iter_andxorskip; //Shows when there is not a skip
.float spawnarray_iter_revitmita; //Reverses the affinity, ita goes first then


.float spawnarray_ita_rows;
.float spawnarray_ita_cols;
.float spawnarray_ita_lvls;
.float spawnarray_ita_row_offset;
.float spawnarray_ita_col_offset;
.float spawnarray_ita_lvl_offset;
.float spawnarray_ita_lvl_addangle;
.vector spawnarray_ita_lvl_addangles;
.float spawnarray_ita_add2offset;

.float spawnarray_ita_iter_skipuntil; 
.float spawnarray_ita_iter_and; 
.float spawnarray_ita_iter_andobeysk; 
.float spawnarray_ita_iter_revitmita;

.float spawnarray_itm_rows;
.float spawnarray_itm_cols;
.float spawnarray_itm_lvls;
.float spawnarray_itm_row_offset;
.float spawnarray_itm_col_offset;
.float spawnarray_itm_lvl_offset;
.float spawnarray_itm_lvl_addangle;
.vector spawnarray_itm_lvl_addangles;
.float spawnarray_itm_add2offset;

.float spawnarray_itm_iter_skipuntil; 
.float spawnarray_itm_iter_and; 
.float spawnarray_itm_iter_andobeysk; 
.float spawnarray_itm_iter_revitmita;

.float spawnarray_skip_cols_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_cols; //Skip every Xnd column (2 skips every 2nd column, 1 skips every column)
.string spawnarray_skip_cols_spawn;
.float spawnarray_skip_cols_shift;
.float spawnarray_skip_cols_ioffset; //iterative offset
.float spawnarray_skip_cols_rotate;
.float spawnarray_skip_cols_sno; //Enact checks
.float spawnarray_skip_cols_sn2; //Enact checks
.float spawnarray_skip_cols_sn3; //Enact checks

.float spawnarray_skip_rows_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_rows; //Skip every Xnd row
.string spawnarray_skip_rows_spawn;
.float spawnarray_skip_rows_shift;
.float spawnarray_skip_rows_ioffset; //iterative offset
.float spawnarray_skip_rows_rotate;
.float spawnarray_skip_rows_sno; //Enact checks
.float spawnarray_skip_rows_sn2; //Enact checks
.float spawnarray_skip_rows_sn3; //Enact checks

.string spawnarray_skip_rc_spawn; //When both a skiprow and skipcolumn, spawn this
.float spawnarray_skip_rc_rotate;
.float spawnarray_skip_rc_sno; //Enact checks
.float spawnarray_skip_rc_sn2; //Enact checks
.float spawnarray_skip_rc_sn3; //Enact checks

.float spawnarray_skip_lvls_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_lvls; //Skip every Xnd lvl
.string spawnarray_skip_lvls_spawn;
.float spawnarray_skip_lvls_shift;
.float spawnarray_skip_lvls_ioffset; //iterative offset
.float spawnarray_skip_lvls_rotate;
.float spawnarray_skip_lvls_sno; //Enact checks
.float spawnarray_skip_lvls_sn2; //Enact checks
.float spawnarray_skip_lvls_sn3; //Enact checks

.string spawnarray_skip_rcl_spawn; //When both a skiprow and skipcolumn and skiplvl, spawn this
.float spawnarray_skip_rcl_rotate;
.float spawnarray_skip_rcl_sno; //Enact checks
.float spawnarray_skip_rcl_sn2; //Enact checks
.float spawnarray_skip_rcl_sn3; //Enact checks

.float spawnarray_row_ioffset; //iterative offset
.float spawnarray_col_ioffset; //iterative offset
.float spawnarray_lvl_ioffset; //iterative offset

.float spawnarray_perimeteronly; //Spawn only in perimeter
.float spawnarray_perimeteronly_lvls; //also levels


.float spawnarray_spawn_delay; //Delayspawn
.float spawnarray_spawn_delayjitter; //Jitter to add
.string spawnarray_delay_spawn; //Used internally
float spawnarray_delay_simulated_mintime;
float spawnarray_delay_simulated_maxtime;
.float spawnarray_delay_simulated; //Used internally
.float spawnarray_delay_simnexttime;//Used internally
.float spawnarray_spawn_delaymethod; //Decide what method, changes how many entities used etc
.float spawnarray_spawn_delaymthdft; //how to discover the entities
 
float autocvar_g_spawnarray_spawn_delaymethod_default; //Default delay method
float autocvar_g_spawnarray_spawn_delaymthdft_default; //Default findtype for method 3


.float spawnarray_skip_cols2_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_cols2; //Skip every Xnd column (2 skips every 2nd column, 1 skips every column)
.string spawnarray_skip_cols2_spawn;
.float spawnarray_skip_cols2_shift;
.float spawnarray_skip_cols2_ioffset; //iterative offset
.float spawnarray_skip_cols2_rotate;
.float spawnarray_skip_cols2_sno; //Enact checks
.float spawnarray_skip_cols2_sn2; //Enact checks
.float spawnarray_skip_cols2_sn3; //Enact checks

.float spawnarray_skip_rows2_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_rows2; //Skip every Xnd row
.string spawnarray_skip_rows2_spawn;
.float spawnarray_skip_rows2_shift;
.float spawnarray_skip_rows2_ioffset; //iterative offset
.float spawnarray_skip_rows2_rotate;
.float spawnarray_skip_rows2_sno; //Enact checks
.float spawnarray_skip_rows2_sn2; //Enact checks
.float spawnarray_skip_rows2_sn3; //Enact checks

.string spawnarray_skip_r2c_spawn; //When both a skiprow2 and skipcolumn, spawn this
.float spawnarray_skip_r2c_rotate;
.float spawnarray_skip_r2c_sno; //Enact checks
.float spawnarray_skip_r2c_sn2; //Enact checks
.float spawnarray_skip_r2c_sn3; //Enact checks

.string spawnarray_skip_rc2_spawn; //When both a skiprow and skipcolumn2, spawn this
.float spawnarray_skip_rc2_rotate;
.float spawnarray_skip_rc2_sno; //Enact checks
.float spawnarray_skip_rc2_sn2; //Enact checks
.float spawnarray_skip_rc2_sn3; //Enact checks

.string spawnarray_skip_r2c2_spawn; //When both a skiprow2 and skipcolumn2, spawn this
.float spawnarray_skip_r2c2_rotate;
.float spawnarray_skip_r2c2_sno; //Enact checks
.float spawnarray_skip_r2c2_sn2; //Enact checks
.float spawnarray_skip_r2c2_sn3; //Enact checks

//
.string spawnarray_skip_r2cl_spawn; //When both a skiprow2 and skipcolumn and skiplvl, spawn this
.float spawnarray_skip_r2cl_rotate;
.float spawnarray_skip_r2cl_sno; //Enact checks
.float spawnarray_skip_r2cl_sn2; //Enact checks
.float spawnarray_skip_r2cl_sn3; //Enact checks

.string spawnarray_skip_rc2l_spawn; //When both a skiprow and skipcolumn2 and skiplvl, spawn this
.float spawnarray_skip_rc2l_rotate;
.float spawnarray_skip_rc2l_sno; //Enact checks
.float spawnarray_skip_rc2l_sn2; //Enact checks
.float spawnarray_skip_rc2l_sn3; //Enact checks

.string spawnarray_skip_r2c2l_spawn; //When both a skiprow2 and skipcolumn2 and skiplvl, spawn this
.float spawnarray_skip_r2c2l_rotate;
.float spawnarray_skip_r2c2l_sno; //Enact checks
.float spawnarray_skip_r2c2l_sn2; //Enact checks
.float spawnarray_skip_r2c2l_sn3; //Enact checks
//

//

.float spawnarray_skip_cols3_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_cols3; //Skip every Xnd column (2 skips every 2nd column, 1 skips every column)
.string spawnarray_skip_cols3_spawn;
.float spawnarray_skip_cols3_shift;
.float spawnarray_skip_cols3_ioffset; //iterative offset
.float spawnarray_skip_cols3_rotate;
.float spawnarray_skip_cols3_sno; //Enact checks
.float spawnarray_skip_cols3_sn2; //Enact checks
.float spawnarray_skip_cols3_sn3; //Enact checks

.float spawnarray_skip_rows3_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_rows3; //Skip every Xnd row
.string spawnarray_skip_rows3_spawn;
.float spawnarray_skip_rows3_shift;
.float spawnarray_skip_rows3_ioffset; //iterative offset
.float spawnarray_skip_rows3_rotate;
.float spawnarray_skip_rows3_sno; //Enact checks
.float spawnarray_skip_rows3_sn2; //Enact checks
.float spawnarray_skip_rows3_sn3; //Enact checks

.string spawnarray_skip_r3c_spawn; //When both a skiprow3 and skipcolumn, spawn this
.float spawnarray_skip_r3c_rotate;
.float spawnarray_skip_r3c_sno; //Enact checks
.float spawnarray_skip_r3c_sn2; //Enact checks
.float spawnarray_skip_r3c_sn3; //Enact checks

.string spawnarray_skip_rc3_spawn; //When both a skiprow and skipcolumn3, spawn this
.float spawnarray_skip_rc3_rotate;
.float spawnarray_skip_rc3_sno; //Enact checks
.float spawnarray_skip_rc3_sn2; //Enact checks
.float spawnarray_skip_rc3_sn3; //Enact checks

.string spawnarray_skip_r3c3_spawn; //When both a skiprow3 and skipcolumn3, spawn this
.float spawnarray_skip_r3c3_rotate;
.float spawnarray_skip_r3c3_sno; //Enact checks
.float spawnarray_skip_r3c3_sn2; //Enact checks
.float spawnarray_skip_r3c3_sn3; //Enact checks


.string spawnarray_skip_r3c2_spawn; //When both a skiprow3 and skipcolumn2, spawn this
.float spawnarray_skip_r3c2_rotate;
.float spawnarray_skip_r3c2_sno; //Enact checks
.float spawnarray_skip_r3c2_sn2; //Enact checks
.float spawnarray_skip_r3c2_sn3; //Enact checks

.string spawnarray_skip_r2c3_spawn; //When both a skiprow2 and skipcolumn3, spawn this
.float spawnarray_skip_r2c3_rotate;
.float spawnarray_skip_r2c3_sno; //Enact checks
.float spawnarray_skip_r2c3_sn2; //Enact checks
.float spawnarray_skip_r2c3_sn3; //Enact checks

//Note: not doing levels for row3, column3
//



.float spawnarray_skip_cols4_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_cols4; //Skip every Xnd column (2 skips every 2nd column, 1 skips every column)
.string spawnarray_skip_cols4_spawn;
.float spawnarray_skip_cols4_shift;
.float spawnarray_skip_cols4_ioffset; //iterative offset
.float spawnarray_skip_cols4_rotate;
.float spawnarray_skip_cols4_sno; //Enact checks
.float spawnarray_skip_cols4_sn2; //Enact checks
.float spawnarray_skip_cols4_sn3; //Enact checks

.float spawnarray_skip_rows4_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_rows4; //Skip every Xnd row
.string spawnarray_skip_rows4_spawn;
.float spawnarray_skip_rows4_shift;
.float spawnarray_skip_rows4_ioffset; //iterative offset
.float spawnarray_skip_rows4_rotate;
.float spawnarray_skip_rows4_sno; //Enact checks
.float spawnarray_skip_rows4_sn2; //Enact checks
.float spawnarray_skip_rows4_sn3; //Enact checks

.string spawnarray_skip_r4c_spawn; //When both a skiprow4 and skipcolumn, spawn this
.float spawnarray_skip_r4c_rotate;
.float spawnarray_skip_r4c_sno; //Enact checks
.float spawnarray_skip_r4c_sn2; //Enact checks
.float spawnarray_skip_r4c_sn3; //Enact checks

.string spawnarray_skip_rc4_spawn; //When both a skiprow and skipcolumn4, spawn this
.float spawnarray_skip_rc4_rotate;
.float spawnarray_skip_rc4_sno; //Enact checks
.float spawnarray_skip_rc4_sn2; //Enact checks
.float spawnarray_skip_rc4_sn3; //Enact checks

.string spawnarray_skip_r4c4_spawn; //When both a skiprow4 and skipcolumn4, spawn this
.float spawnarray_skip_r4c4_rotate;
.float spawnarray_skip_r4c4_sno; //Enact checks
.float spawnarray_skip_r4c4_sn2; //Enact checks
.float spawnarray_skip_r4c4_sn3; //Enact checks


.string spawnarray_skip_r4c2_spawn; //When both a skiprow4 and skipcolumn2, spawn this
.float spawnarray_skip_r4c2_rotate;
.float spawnarray_skip_r4c2_sno; //Enact checks
.float spawnarray_skip_r4c2_sn2; //Enact checks
.float spawnarray_skip_r4c2_sn3; //Enact checks

.string spawnarray_skip_r2c4_spawn; //When both a skiprow2 and skipcolumn4, spawn this
.float spawnarray_skip_r2c4_rotate;
.float spawnarray_skip_r2c4_sno; //Enact checks
.float spawnarray_skip_r2c4_sn2; //Enact checks
.float spawnarray_skip_r2c4_sn3; //Enact checks


.string spawnarray_skip_r4c3_spawn; //When both a skiprow4 and skipcolumn2, spawn this
.float spawnarray_skip_r4c3_rotate;
.float spawnarray_skip_r4c3_sno; //Enact checks
.float spawnarray_skip_r4c3_sn2; //Enact checks
.float spawnarray_skip_r4c3_sn3; //Enact checks

.string spawnarray_skip_r3c4_spawn; //When both a skiprow2 and skipcolumn4, spawn this
.float spawnarray_skip_r3c4_rotate;
.float spawnarray_skip_r3c4_sno; //Enact checks
.float spawnarray_skip_r3c4_sn2; //Enact checks
.float spawnarray_skip_r3c4_sn3; //Enact checks

//Note: not doing levels for row4, column4
//

//

.float spawnarray_skip_cols5_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_cols5; //Skip every Xnd column (2 skips every 2nd column, 1 skips every column)
.string spawnarray_skip_cols5_spawn;
.float spawnarray_skip_cols5_shift;
.float spawnarray_skip_cols5_ioffset; //iterative offset
.float spawnarray_skip_cols5_rotate;
.float spawnarray_skip_cols5_sno; //Enact checks
.float spawnarray_skip_cols5_sn2; //Enact checks
.float spawnarray_skip_cols5_sn3; //Enact checks

.float spawnarray_skip_rows5_noadjust; //Don't adjust iteroffset sizes.
.float spawnarray_skip_rows5; //Skip every Xnd row
.string spawnarray_skip_rows5_spawn;
.float spawnarray_skip_rows5_shift;
.float spawnarray_skip_rows5_ioffset; //iterative offset
.float spawnarray_skip_rows5_rotate;
.float spawnarray_skip_rows5_sno; //Enact checks
.float spawnarray_skip_rows5_sn2; //Enact checks
.float spawnarray_skip_rows5_sn3; //Enact checks

.string spawnarray_skip_r5c_spawn; //When both a skiprow5 and skipcolumn, spawn this
.float spawnarray_skip_r5c_rotate;
.float spawnarray_skip_r5c_sno; //Enact checks
.float spawnarray_skip_r5c_sn2; //Enact checks
.float spawnarray_skip_r5c_sn3; //Enact checks

.string spawnarray_skip_rc5_spawn; //When both a skiprow and skipcolumn5, spawn this
.float spawnarray_skip_rc5_rotate;
.float spawnarray_skip_rc5_sno; //Enact checks
.float spawnarray_skip_rc5_sn2; //Enact checks
.float spawnarray_skip_rc5_sn3; //Enact checks

.string spawnarray_skip_r5c5_spawn; //When both a skiprow5 and skipcolumn5, spawn this
.float spawnarray_skip_r5c5_rotate;
.float spawnarray_skip_r5c5_sno; //Enact checks
.float spawnarray_skip_r5c5_sn2; //Enact checks
.float spawnarray_skip_r5c5_sn3; //Enact checks


.string spawnarray_skip_r5c2_spawn; //When both a skiprow5 and skipcolumn2, spawn this
.float spawnarray_skip_r5c2_rotate;
.float spawnarray_skip_r5c2_sno; //Enact checks
.float spawnarray_skip_r5c2_sn2; //Enact checks
.float spawnarray_skip_r5c2_sn3; //Enact checks

.string spawnarray_skip_r2c5_spawn; //When both a skiprow2 and skipcolumn5, spawn this
.float spawnarray_skip_r2c5_rotate;
.float spawnarray_skip_r2c5_sno; //Enact checks
.float spawnarray_skip_r2c5_sn2; //Enact checks
.float spawnarray_skip_r2c5_sn3; //Enact checks


.string spawnarray_skip_r5c3_spawn; //When both a skiprow5 and skipcolumn2, spawn this
.float spawnarray_skip_r5c3_rotate;
.float spawnarray_skip_r5c3_sno; //Enact checks
.float spawnarray_skip_r5c3_sn2; //Enact checks
.float spawnarray_skip_r5c3_sn3; //Enact checks

.string spawnarray_skip_r3c5_spawn; //When both a skiprow2 and skipcolumn5, spawn this
.float spawnarray_skip_r3c5_rotate;
.float spawnarray_skip_r3c5_sno; //Enact checks
.float spawnarray_skip_r3c5_sn2; //Enact checks
.float spawnarray_skip_r3c5_sn3; //Enact checks


.string spawnarray_skip_r5c4_spawn; //When both a skiprow5 and skipcolumn2, spawn this
.float spawnarray_skip_r5c4_rotate;
.float spawnarray_skip_r5c4_sno; //Enact checks
.float spawnarray_skip_r5c4_sn2; //Enact checks
.float spawnarray_skip_r5c4_sn3; //Enact checks

.string spawnarray_skip_r4c5_spawn; //When both a skiprow2 and skipcolumn5, spawn this
.float spawnarray_skip_r4c5_rotate;
.float spawnarray_skip_r4c5_sno; //Enact checks
.float spawnarray_skip_r4c5_sn2; //Enact checks
.float spawnarray_skip_r4c5_sn3; //Enact checks

//Note: not doing levels for row5, column5
//


.float spawnarray_spawn_no_solid;
.float spawnarray_spawn_no_water;
.float spawnarray_spawn_no_lava;
.float spawnarray_spawn_no_slime;
.float spawnarray_spawn_no_sky;
.float spawnarray_spawn_no_area; //X by X area to check
.float spawnarray_spawn_no_arear;//Set if you want the right side to be different
.float spawnarray_spawn_no_up;   //go up and do the same
.float spawnarray_spawn_no_down; //go down and do the same
.float spawnarray_spawn_no_brthld; //blockratethreshold
.float spawnarray_spawn_no_zofset; //offset (set to negative to search down (ex for water)
.float spawnarray_spawn_no_trdown; //tracedown
.float spawnarray_spawn_no_nomain; //no maincheck, only roads etc

.float spawnarray_spawn_n2_solid;
.float spawnarray_spawn_n2_water;
.float spawnarray_spawn_n2_lava;
.float spawnarray_spawn_n2_slime;
.float spawnarray_spawn_n2_sky;
.float spawnarray_spawn_n2_area; //X by X area to check
.float spawnarray_spawn_n2_arear;//Set if you want the right side to be different
.float spawnarray_spawn_n2_up;   //go up and do the same
.float spawnarray_spawn_n2_down; //go down and do the same
.float spawnarray_spawn_n2_brthld; //blockratethreshold
.float spawnarray_spawn_n2_zofset; //offset (set to negative to search down (ex for water)
.float spawnarray_spawn_n2_trdown; //tracedown
.float spawnarray_spawn_n2_nomain; //no maincheck, only roads etc

.float spawnarray_spawn_n3_solid;
.float spawnarray_spawn_n3_water;
.float spawnarray_spawn_n3_lava;
.float spawnarray_spawn_n3_slime;
.float spawnarray_spawn_n3_sky;
.float spawnarray_spawn_n3_area; //X by X area to check
.float spawnarray_spawn_n3_arear;//Set if you want the right side to be different
.float spawnarray_spawn_n3_up;   //go up and do the same
.float spawnarray_spawn_n3_down; //go down and do the same
.float spawnarray_spawn_n3_brthld; //blockratethreshold
.float spawnarray_spawn_n3_zofset; //offset (set to negative to search down (ex for water)
.float spawnarray_spawn_n3_trdown; //tracedown
.float spawnarray_spawn_n3_nomain; //no maincheck, only roads etc

.float spawnarray_removeunused;

.float spawnarray_moveorigin_forward; //Move origin by v_forward etc
.float spawnarray_moveorigin_right;
.float spawnarray_moveorigin_up;
.vector spawnarray_moveorigin; //Move origin by xyz


///////
.float spawnarray_pauseafterrows;
.float spawnarray_pauseafterrowstime;

.float resumespawnarray;
.float savedspawnarraycol;
.float savedspawnarraylvl;
.float savedspawnarrayrow;
.vector saved_sa_lastorigin;
//.float saved_sa_addspawnprefix;
///////

float lastspawnarrayid; //When we spawn a new spawn array we increment this
.float spawnarray_id;
.float spawnarray_id_membertype; //0 is the array itself, 1 is a normal spawn, 2 a skip? 
.float spawnarray_id_generation;
.float spawnarray_id_lvl; //The spawned item's lvl
.float spawnarray_id_row; //The spawned item's row
.float spawnarray_id_col; //The spawned item's colum

.float spawnarray_sctilesrectify; //rectify large buildings as per the grid

//
void spawnarray_rectifysctileslargebuildings(float myspawnarrayid, float myspawnarrayspawnflags);
void spawnfunc_spawnarray(void);
void do_spawnarray(void);

void spawnarraysctilesrectifyafterdelay(float myspawnarrayid, float myspawnarrayspawnflags, entity myself, float mydelay, float myjitter);
float autocvar_sv_spawnarraysctilesrectify_noprint;


/////////////////////////////////////////////////////////////////////
/////// Array spawn point blocking spawns if in solid et al /////////
/////////////////////////////////////////////////////////////////////
float spawnarraypointblocked (vector myorigin, float nosolid, float nowater, float nolava, float noslime, float nosky)
{
	
	local float mycontents;
	mycontents = pointcontents (myorigin);
	if (mycontents == CONTENT_SOLID && nosolid) {
		return 1;
	} else if (mycontents == CONTENT_WATER && nowater) {
		return 1;
	} else if (mycontents == CONTENT_LAVA && nolava) {
		return 1;
	} else if (mycontents == CONTENT_SLIME && noslime) {
		return 1;
	//No sora
	} else if (mycontents == CONTENT_SKY && nosky) {
		return 1;
	}
	
	return 0;
}
	

float spawnarrayspawnno_allowspawn(entity myself, float myblockratethreshold, float myzoffset, float mytracedown, float myarea, float myarearight, float myup, float mydown, float nosolid, float nowater, float nolava, float noslime, float nosky, float doprints)
{
	if (nosolid || nowater || nolava || noslime || nosky) {
		//Restrictions?
	} else {
		//No restrictions
		return TRUE;
	}
	
	local vector myold_v_forward;
	local vector myold_v_right;
	local vector myold_v_up;
	local vector myorigin;
	local vector myoriginbase;
	local vector posttracedownorigin;
	local float mypoints;
	local float myblockedpoints = 0;
	local float myf, myr;
	
	//Make sure positive;
	if (mydown < 0) mydown = mydown * -1;
	if (myup < 0) myup = myup * -1;
	
	
	mypoints = 1;
	
	if (myarea) {
		mypoints = mypoints + 8; //f, -f, r, -r, fr, f-r, -fr, -f-r
		myf = myarea;
		if (myarearight) {
			myr = myarearight;
		} else {
			myr = myarea;
		}
	} else if (myarearight) {
		//No myarea set, but y set, will use y
		mypoints = mypoints + 8;
		myarea = myarearight;
		myf = myarearight;
		myr = myarearight;
	}
	
	if (myup && mydown) {
		mypoints = mypoints * 3;
	} else if (myup || mydown) {
		mypoints = mypoints * 2;
	}

	myold_v_forward = v_forward;
	myold_v_right = v_right;
	myold_v_up = v_up;
	
		
	makevectors(myself.angles);
	
	if (mytracedown) {
		local vector mytracedownvector;
		local vector myoldtraceendpos;
		local vector myoldpos;
		
		//Save
		myoldtraceendpos = trace_endpos;
		myoldpos = myself.origin;
		
		mytracedownvector_x = 0;
		mytracedownvector_y = 0;
		mytracedownvector_z = mytracedown;
		traceline(myself.origin + '0 0 2', myself.origin - mytracedownvector, MOVE_WORLDONLY, myself);
		posttracedownorigin = trace_endpos;
		
		//Reset
		trace_endpos = myoldtraceendpos;
		myself.origin = myoldpos; //Just to be safe;
	} else {
		posttracedownorigin = myself.origin;
	}
	
	myoriginbase = posttracedownorigin;
	if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
	
	myorigin = myoriginbase;
	myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
	if (myup) {
		myorigin = myoriginbase + (v_up * myup);
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
	}
	if (mydown) {
		myorigin = myoriginbase - (v_up * mydown);
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
	}
	
	
	if (myarea) {
		//Forward
		myoriginbase = posttracedownorigin + (v_forward * myf);
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		
		//-forward
		myoriginbase = posttracedownorigin + (v_forward * (myf * -1));
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		
		//////////////////////////
		
		//right
		myoriginbase = posttracedownorigin + (v_forward * myr);
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		
		//-right
		myoriginbase = posttracedownorigin + (v_forward * (myr * -1));
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		
		//////////////////////////
		//////////////////////////
		
		//Forward Right
		myoriginbase = posttracedownorigin + (v_forward * myf) + (v_right * myr);
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		
		//-Forward Right
		myoriginbase = posttracedownorigin + (v_forward * (myf * -1)) + (v_right * myr);
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		
		//////////////////////////
		
		//Forward -Right
		myoriginbase = posttracedownorigin + (v_forward * myf) + (v_right * (myr * -1));
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		
		//-Forward -Right
		myoriginbase = posttracedownorigin + (v_forward * (myf * -1)) + (v_right * (myr * -1));
		if (myzoffset) { myoriginbase = myoriginbase + (v_up * myzoffset); }
		myorigin = myoriginbase;
		myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		if (myup) {
			myorigin = myoriginbase + (v_up * myup);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
		if (mydown) {
			myorigin = myoriginbase - (v_up * mydown);
			myblockedpoints += spawnarraypointblocked (myorigin, nosolid, nowater, nolava, noslime, nosky);
		}
	}
		
	//Reset
	v_forward = myold_v_forward;
	v_right = myold_v_right;
	v_up = myold_v_up;
	
	if (doprints) print (" * * SpAwNaRrAy Checking Blocked: ", ftos(myblockedpoints), " blocked points out of", ftos(mypoints), "\n");
	
	if (myblockratethreshold) {
		if (myblockratethreshold >= (myblockedpoints / mypoints)) {
			if (doprints) print(ftos(myblockratethreshold), " exceeded by ", ftos(myblockedpoints / mypoints), "thus BLOCK spawn\n");
			return FALSE;
		} else {
			if (doprints) print(ftos(myblockratethreshold), " NOT exceeded by ", ftos(myblockedpoints / mypoints), "thus ALLOW spawn\n");
			return TRUE;
		}
	} else if (myblockedpoints == mypoints) {
		//All points blocked, no spawn allowed
		if (doprints) print(" All points blocked thus BLOCK spawn\n");
		return FALSE;
	} else {
		if (doprints) print(" ALLOW spawn\n");
		return TRUE;
	}
}
/////////////////////////////////////////////////////////////////////
/////// END Array spawn point blocking spawns if in solid   /////////
/////////////////////////////////////////////////////////////////////



float spawnarraydelaymethod3_time() {
	if (self.spawnarray_delay_simulated) {
		self.spawnarray_delay_simulated = 0;
		self.spawnarray_delay_simnexttime = 0;
		if(isfunction(self.spawnarray_delay_spawn)) {
			callfunction(self.spawnarray_delay_spawn);
			return TRUE;
		}
	}
	
	return FALSE;
}

vector spawnarraydelaymethod3_iter(float mintime, float findtype) {
	local entity myoldself2;
	local vector myreturnvec;
	local float entitiesinitialized = 0;
	local float entitiestotal = 0;
	local entity f;
	
	myoldself2 = self;
	
	
	if (findtype == 1) {
		//2nd way, more correct but doesn't look as good
		//Does the work in batches, as originally intended
		//You can set this setting autocvar_g_spawnarray_spawn_delaymthdft_default to 1
		//or setting spawnarray_spawn_delaymthdft to 1 on the spawnarray entity
		// (if nothing is set on the spawnarray entity the default will be used)
		f = findchainfloat(spawnarray_delay_simulated, TRUE);
	} else {
		//Not quite "correct", but it was the original and may give
		//different results
		//You can set this using autocvar_g_spawnarray_spawn_delaymthdft_default (to 0 or 2)
		//or setting spawnarray_spawn_delaymthdft on the spawnarray entity (to 2)
		// (if nothing is set on the spawnarray entity the default will be used)
		//
		//Gives more organic results
		f = findfloat(world, spawnarray_delay_simulated, TRUE);
	}
	
	while (f)
	{
		if (f.spawnarray_delay_simnexttime < mintime) {
			self = f;
			if (spawnarraydelaymethod3_time()) {
				entitiesinitialized++;
			}
			self = myoldself2;
		}
		
		if (f != world) {
			entitiestotal++;
		}
		
		f = f.chain;
	}
	
	myreturnvec_x = entitiesinitialized;
	myreturnvec_y = entitiestotal;
	myreturnvec_z = 0;
	
	return myreturnvec;
}

//
// Spawn-Delay Method 3
//
//A "Simulated" delay
//Reason to prefer this method: LOD works well when everything is spawned before player connects
//You can use the other methods if you like the effect of the buildings slowly arriving
//But there are troubles with LOD for players who joined the server beforehand (atleast player 0)
//
//This is set as the default. You, the mapper, can change it with spawnarray_spawn_delaymethod in your entity, however
//

void spawnarraydelaymethod3_do(float mytimeslice, float myfindtype) {
	local vector rtrnvec;
	local entity myoldself;
	float simulatedtime = 0;
	float myamntentities;
	float myentitiesleft;
	
	if (!mytimeslice) { mytimeslice = 0.1; } //Set default if not specified
	if (mytimeslice < 0) { mytimeslice = mytimeslice * -1; } //No negative timeslices
	
	myoldself = self;
	
			if (autocvar_sv_spawnarraysctilesrectify_noprint < 2) print("^xF2Fspawnarray: Starting simulated delay^7\n");
	if (spawnarray_delay_simulated_mintime) {
		simulatedtime = spawnarray_delay_simulated_mintime - 0.1;
		if (simulatedtime < 0) {
			simulatedtime = 0;
		}
	}
	
	myentitiesleft = 1;
	
	//Previously we tried a simulated"time" method //
	// while (simulatedtime < (spawnarray_delay_simulated_maxtime + mytimeslice + 10)) {
	// The 10 was because it wouldn't spawn some otherwise
	// Showing that our code was deficient in some way //
	// Thus we try a different method //
	// Here we now spawn until no more of the needed-to-spawn entities are around //
	//
	// at that point, we stop.
	
	
	while (myentitiesleft) {
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 2) print("^xF2F-------------------------------^7\n");
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 2) print("SpawnArray Simulating ", ftos(simulatedtime), " time \n");
		rtrnvec = spawnarraydelaymethod3_iter(simulatedtime, myfindtype);
		myamntentities = rtrnvec_x;
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 2) print(ftos(myamntentities), " initialized for ", ftos(simulatedtime), " time\n");
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 2) print("^xF2F-------------------------------^7\n");
		simulatedtime = simulatedtime + mytimeslice;
		myentitiesleft = rtrnvec_y;
	}
	
	self = myoldself;
}

void spawnarraydelaymethod3(entity myself, string myspwnfnctn, float mydelay, float myjitter) {
	 myself.spawnarray_delay_spawn = strzone(myspwnfnctn);
	 myself.spawnarray_delay_simulated = 1;
	 myself.spawnarray_delay_simnexttime = mydelay + (random() * myjitter);
	 
	 if (!spawnarray_delay_simulated_mintime) {
	 	spawnarray_delay_simulated_mintime = myself.spawnarray_delay_simnexttime;
	 }
	 
	 if (myself.spawnarray_delay_simnexttime > spawnarray_delay_simulated_maxtime) {
	 	spawnarray_delay_simulated_maxtime = myself.spawnarray_delay_simnexttime;
	 }
	 
	 if (myself.spawnarray_delay_simnexttime < spawnarray_delay_simulated_mintime) {
	 	spawnarray_delay_simulated_mintime = myself.spawnarray_delay_simnexttime;
	 }
}

//
// Spawn-Delay Method 2: copy entity, spawn new entity, remove old entity
//

void spawnarraydelaymethod2_think() {
	local entity myoldself;
	local entity mynewentity;
	
	myoldself = self;
	mynewentity = spawn();
	//
	
	copyentity(myoldself, mynewentity);
	self = mynewentity;
	
	setorigin (mynewentity, myoldself.origin);
	
			if (autocvar_sv_spawnarraysctilesrectify_noprint < 2) print("2SpawnDelayMethod2\n");
	if(isfunction(myoldself.spawnarray_delay_spawn)) {
		callfunction(myoldself.spawnarray_delay_spawn);
	}
	
	self = myoldself;
	remove(self);
}

void spawnarraydelaymethod2(entity myself, string myspwnfnctn, float mydelay, float myjitter) {
	 myself.spawnarray_delay_spawn = strzone(myspwnfnctn);
	 myself.think = spawnarraydelaymethod2_think;
	 myself.nextthink = time + mydelay + (random() * myjitter);
}

//
// Spawn-Delay Method 1 : the traditional way, however this wastes entities for a small period of time
// which can cause one to reach the limit quicker. (The extra entities are removed later)
//

void spawnarraydelay_think() {
	local entity myoldself;
	if (self) {
		if (self.subordinate) {
			
			
			myoldself = self;
			self = myoldself.subordinate;
	
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 2) print("1SpawnDelayMethod1\n");
			if(isfunction(myoldself.spawnarray_delay_spawn)) {
				callfunction(myoldself.spawnarray_delay_spawn);
			}
		
			self = myoldself;
		}
	}
	remove(self);
}

void spawnarraydelaymethod1(entity myself, string myspwnfnctn, float mydelay, float myjitter) {
	 
	 entity myspawner;
	 myspawner = spawn();
	 myspawner.subordinate = myself;
	 myspawner.spawnarray_delay_spawn = strzone(myspwnfnctn);
	 myspawner.think = spawnarraydelay_think;
	 myspawner.nextthink = time + mydelay + (random() * myjitter);
}

void spawnarraydelay(float mymethod, entity myself, string myspwnfnctn, float mydelay, float myjitter) {
	if (!mymethod) {
		mymethod = autocvar_g_spawnarray_spawn_delaymethod_default;
	} 
	
	if (autocvar_g_spawnarray_spawn_delaymethod_default < 0) {
		//Force
		mymethod = autocvar_g_spawnarray_spawn_delaymethod_default * -1;
	}
	
	if (mymethod == 1) {
		//1
		spawnarraydelaymethod1(myself, myspwnfnctn, mydelay, myjitter); //More "traditional"
	} else if (mymethod == 2) {
		//2
	 	spawnarraydelaymethod2(myself, myspwnfnctn, mydelay, myjitter); //Uses less entities
	} else {
		//3
	 	spawnarraydelaymethod3(myself, myspwnfnctn, mydelay, myjitter); //Uses less entities
	}
	
}


void spawnarray_ita_apply(void) {
	
	if (self.spawnarray_ita_rows ) {
		self.spawnarray_rows = 
		self.spawnarray_rows +
		self.spawnarray_ita_rows;
	}
	
	if (self.spawnarray_ita_cols) {
		self.spawnarray_cols = 
		self.spawnarray_cols +
		self.spawnarray_ita_cols;
	}
	
	if (self.spawnarray_ita_lvls) {
		self.spawnarray_lvls = 
		self.spawnarray_lvls +
		self.spawnarray_ita_lvls;
	}
	
	if (self.spawnarray_ita_row_offset) {
		self.spawnarray_row_offset = 
		self.spawnarray_row_offset +
		self.spawnarray_ita_row_offset;
	}
	
	if (self.spawnarray_ita_col_offset) {
		self.spawnarray_col_offset = 
		self.spawnarray_col_offset +
		self.spawnarray_ita_col_offset;
	}
	
	if (self.spawnarray_ita_lvl_offset) {
		self.spawnarray_lvl_offset = 
		self.spawnarray_lvl_offset +
		self.spawnarray_ita_lvl_offset;
	}
	
	if (self.spawnarray_ita_lvl_addangle) {
		self.spawnarray_lvl_addangle = 
		self.spawnarray_lvl_addangle +
		self.spawnarray_ita_lvl_addangle;
	}
	
	if (self.spawnarray_ita_lvl_addangles_x) {
		self.spawnarray_lvl_addangles_x =
		self.spawnarray_lvl_addangles_x +
		self.spawnarray_ita_lvl_addangles_x;
	}

	if (self.spawnarray_ita_lvl_addangles_y) {
		self.spawnarray_lvl_addangles_y =
		self.spawnarray_lvl_addangles_y +
		self.spawnarray_ita_lvl_addangles_y;
	}

	if (self.spawnarray_ita_lvl_addangles_z) {
		self.spawnarray_lvl_addangles_z =
		self.spawnarray_lvl_addangles_z +
		self.spawnarray_ita_lvl_addangles_z;
	}



	if (self.spawnarray_ita_iter_skipuntil) {
		self.spawnarray_iter_skipuntil =
		self.spawnarray_iter_skipuntil +
		self.spawnarray_ita_iter_skipuntil;
	}

	if (self.spawnarray_ita_iter_and) {
		self.spawnarray_iter_and =
		self.spawnarray_iter_and +
		self.spawnarray_ita_iter_and;
	}

	if (self.spawnarray_ita_iter_andobeysk) {
		self.spawnarray_iter_andobeyskip =
		self.spawnarray_iter_andobeyskip +
		self.spawnarray_ita_iter_andobeysk;
	}

	if (self.spawnarray_ita_iter_revitmita) {
		//Not really practical unless you want to slowly move up to 1 and then from then on...
		self.spawnarray_iter_revitmita =
		self.spawnarray_iter_revitmita +
		self.spawnarray_ita_iter_revitmita;
	}
}


void spawnarray_itm_apply(void) {
	
	if (self.spawnarray_itm_rows) {
		self.spawnarray_rows = 
		self.spawnarray_rows *
		self.spawnarray_itm_rows;
	}
	
	if (self.spawnarray_itm_cols) {
		self.spawnarray_cols = 
		self.spawnarray_cols *
		self.spawnarray_itm_cols;
	}
	
	if (self.spawnarray_itm_lvls) {
		self.spawnarray_lvls = 
		self.spawnarray_lvls *
		self.spawnarray_itm_lvls;
	}
	
	if (self.spawnarray_itm_row_offset) {
		self.spawnarray_row_offset = 
		self.spawnarray_row_offset *
		self.spawnarray_itm_row_offset;
	}
	
	if (self.spawnarray_itm_col_offset) {
		self.spawnarray_col_offset = 
		self.spawnarray_col_offset *
		self.spawnarray_itm_col_offset;
	}
	
	if (self.spawnarray_itm_lvl_offset) {
		self.spawnarray_lvl_offset = 
		self.spawnarray_lvl_offset *
		self.spawnarray_itm_lvl_offset;
	}
	
	if (self.spawnarray_itm_lvl_addangle) {
		self.spawnarray_lvl_addangle = 
		self.spawnarray_lvl_addangle *
		self.spawnarray_itm_lvl_addangle;
	}
	
	if (self.spawnarray_itm_lvl_addangles_x) {
		self.spawnarray_lvl_addangles_x =
		self.spawnarray_lvl_addangles_x *
		self.spawnarray_itm_lvl_addangles_x;
	}

	if (self.spawnarray_itm_lvl_addangles_y) {
		self.spawnarray_lvl_addangles_y =
		self.spawnarray_lvl_addangles_y *
		self.spawnarray_itm_lvl_addangles_y;
	}

	if (self.spawnarray_itm_lvl_addangles_z) {
		self.spawnarray_lvl_addangles_z =
		self.spawnarray_lvl_addangles_z *
		self.spawnarray_itm_lvl_addangles_z;
	}



	if (self.spawnarray_itm_iter_skipuntil) {
		self.spawnarray_iter_skipuntil =
		self.spawnarray_iter_skipuntil *
		self.spawnarray_itm_iter_skipuntil;
	}

	if (self.spawnarray_itm_iter_and) {
		self.spawnarray_iter_and =
		self.spawnarray_iter_and *
		self.spawnarray_itm_iter_and;
	}

	if (self.spawnarray_itm_iter_andobeysk) {
		self.spawnarray_iter_andobeyskip =
		self.spawnarray_iter_andobeyskip *
		self.spawnarray_itm_iter_andobeysk;
	}

	if (self.spawnarray_itm_iter_revitmita) {
		self.spawnarray_iter_revitmita =
		self.spawnarray_iter_revitmita *
		self.spawnarray_itm_iter_revitmita;
	}
}


void makevectorsforspawnarray (entity myoldentity, entity myselfent)
{
		//print("\n\n***MakingVectors***\n\n");
		
		if (myoldentity.spawnarray_reversex && myoldentity.spawnarray_reversey && myoldentity.spawnarray_reversez)
		{
			makevectors(myselfent.angles_x * '-1 0 0' + myselfent.angles_y * '0 -1 0' + myselfent.angles_z * '0 0 -1');
		} else if (myoldentity.spawnarray_reversex && myoldentity.spawnarray_reversey)
		{
			makevectors(myselfent.angles_x * '-1 0 0' + myselfent.angles_y * '0 -1 0' + myselfent.angles_z * '0 0 1');
		} else if (myoldentity.spawnarray_reversex && myoldentity.spawnarray_reversez)
		{
			makevectors(myselfent.angles_x * '-1 0 0' + myselfent.angles_y * '0 1 0' + myselfent.angles_z * '0 0 -1');
		} else if (myoldentity.spawnarray_reversey && myoldentity.spawnarray_reversez)
		{
			makevectors(myselfent.angles_x * '1 0 0' + myselfent.angles_y * '0 -1 0' + myselfent.angles_z * '0 0 -1');
		} else if (myoldentity.spawnarray_reversex)
		{
			//Information on why it's not simply makevectors(myselfent.angles);
			//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
			//	have inverted pitch
			//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
			//	if the entity is bsp or sprite, but not if it is a model
			//18:36 <@LordHavoc> inverting the pitch is necessary on models
			//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
			//	where they are correct pitch for models but not for bsp or 
			//	sprite :P

			makevectors(myselfent.angles_x * '-1 0 0' + myselfent.angles_y * '0 1 0' + myselfent.angles_z * '0 0 1');
		} else if (myoldentity.spawnarray_reversey)
		{
			makevectors(myselfent.angles_x * '0 0 0' + myselfent.angles_y * '0 -1 0' + myselfent.angles_z * '0 0 1');
		} else {
			makevectors(myselfent.angles);
		}
}

float spawnarray_populate (float addspawnprefix) {
	float doresumespawnarray;
	doresumespawnarray = 0;
	float hasspawnedone;
	hasspawnedone = 0;
	
	float dospawnarray_sctilesrectify;
	dospawnarray_sctilesrectify = 0;
	float myspawnarray_id;
	float myspawnarray_spawnflags;
	
	vector myadd2offset;
	myadd2offset_x = 0;
	myadd2offset_y = 0;
	myadd2offset_z = 0;
	local float rows, cols, lvls;
	local float skiprows, skipcols, skiplvls;
	local float skiprows2, skipcols2;
	local float skiprows3, skipcols3;
	local float skiprows4, skipcols4;
	local float skiprows5, skipcols5;
	//local float skiprows_shift, skipcols_shift, skiplvls_shift;
	//local float skiprows_ioffset, skipcols_ioffset, skiplvls_ioffset;
	float skiprows_spwn = 0;
	float skipcols_spwn = 0;
	float skiplvls_spwn = 0;
	float skiprows_ioffset = 0;
	float skipcols_ioffset = 0;
	float skiplvls_ioffset = 0;
	float skiprc_spwn = 0;
	float skiprcl_spwn = 0;
	string skiprows_myspwnfnctn;
	string skipcols_myspwnfnctn;
	string skiplvls_myspwnfnctn;
	string skiprc_myspwnfnctn;
	string skiprcl_myspwnfnctn;
	//
	//
	float skiprows2_spwn = 0;
	float skipcols2_spwn = 0;
	float skiprows2_ioffset = 0;
	float skipcols2_ioffset = 0;
	//
	float skipr2c_spwn = 0;
	float skiprc2_spwn = 0;
	float skipr2c2_spwn = 0;
	//
	float skipr2cl_spwn = 0;
	float skiprc2l_spwn = 0;
	float skipr2c2l_spwn = 0;
	//
	string skiprows2_myspwnfnctn;
	string skipcols2_myspwnfnctn;
	//
	string skipr2c_myspwnfnctn;
	string skiprc2_myspwnfnctn;
	string skipr2c2_myspwnfnctn;
	//
	string skipr2cl_myspwnfnctn;
	string skiprc2l_myspwnfnctn;
	string skipr2c2l_myspwnfnctn;
	//
	//
	float skiprows3_spwn = 0;
	float skipcols3_spwn = 0;
	float skiprows3_ioffset = 0;
	float skipcols3_ioffset = 0;
	//
	float skipr3c_spwn = 0;
	float skiprc3_spwn = 0;
	float skipr3c3_spwn = 0;
	//
	float skipr3c2_spwn = 0;
	float skipr2c3_spwn = 0;
	//
	string skiprows3_myspwnfnctn;
	string skipcols3_myspwnfnctn;
	//
	string skipr3c_myspwnfnctn;
	string skiprc3_myspwnfnctn;
	string skipr3c3_myspwnfnctn;
	string skipr3c2_myspwnfnctn;
	string skipr2c3_myspwnfnctn;
	//
	float skiprows4_spwn = 0;
	float skipcols4_spwn = 0;
	float skiprows4_ioffset = 0;
	float skipcols4_ioffset = 0;
	//
	float skipr4c_spwn = 0;
	float skiprc4_spwn = 0;
	float skipr4c4_spwn = 0;
	//
	float skipr4c2_spwn = 0;
	float skipr2c4_spwn = 0;
	//
	float skipr4c3_spwn = 0;
	float skipr3c4_spwn = 0;
	//
	string skiprows4_myspwnfnctn;
	string skipcols4_myspwnfnctn;
	//
	string skipr4c_myspwnfnctn;
	string skiprc4_myspwnfnctn;
	string skipr4c4_myspwnfnctn;
	string skipr4c2_myspwnfnctn;
	string skipr2c4_myspwnfnctn;
	string skipr4c3_myspwnfnctn;
	string skipr3c4_myspwnfnctn;
	//
	//
	float skiprows5_spwn = 0;
	float skipcols5_spwn = 0;
	float skiprows5_ioffset = 0;
	float skipcols5_ioffset = 0;
	//
	float skipr5c_spwn = 0;
	float skiprc5_spwn = 0;
	float skipr5c5_spwn = 0;
	//
	float skipr5c2_spwn = 0;
	float skipr2c5_spwn = 0;
	//
	float skipr5c3_spwn = 0;
	float skipr3c5_spwn = 0;
	//
	float skipr5c4_spwn = 0;
	float skipr4c5_spwn = 0;
	//
	string skiprows5_myspwnfnctn;
	string skipcols5_myspwnfnctn;
	//
	string skipr5c_myspwnfnctn;
	string skiprc5_myspwnfnctn;
	string skipr5c5_myspwnfnctn;
	string skipr5c2_myspwnfnctn;
	string skipr2c5_myspwnfnctn;
	string skipr5c3_myspwnfnctn;
	string skipr3c5_myspwnfnctn;
	string skipr5c4_myspwnfnctn;
	string skipr4c5_myspwnfnctn;
	//
	//
	float skp_rows_cntr, skp_cols_cntr, skp_lvls_cntr;
	float skp_rows2_cntr, skp_cols2_cntr; 
	float skp_rows3_cntr, skp_cols3_cntr;  
	float skp_rows4_cntr, skp_cols4_cntr; 
	float skp_rows5_cntr, skp_cols5_cntr; 
	float perimeteronly = 0;
	float perimeteronlyincllvls = 0;
	local float roffset, coffset, loffset;
	local float i_roffset, i_coffset, i_loffset;
	local vector lastorigin, lastroworigin, lastlvlorigin;
	local float roffsetee, coffsetee, loffsetee;
	local float cur_row, cur_col, cur_lvl;
	local float iterskipcounter;
	
	skiplvls = 0;
	skiprows = 0;
	skipcols = 0;
	skp_rows_cntr = 0;
	skp_cols_cntr = 0;
	skp_lvls_cntr = 0;
	skp_rows2_cntr = 0;
	skp_cols2_cntr = 0;
	skiprows2 = 0;
	skipcols2 = 0;
	skp_rows3_cntr = 0;
	skp_cols3_cntr = 0;
	skiprows3 = 0;
	skipcols3 = 0;
	skp_rows4_cntr = 0;
	skp_cols4_cntr = 0;
	skiprows4 = 0;
	skipcols4 = 0;
	skp_rows5_cntr = 0;
	skp_cols5_cntr = 0;
	skiprows5 = 0;
	skipcols5 = 0;
	
	cur_row = cur_col = cur_lvl = 0;
	iterskipcounter = 0; //This is a counter for iters, _not_ skiprows etc, don't confuse
	roffsetee = coffsetee = loffsetee = 0;
	i_roffset = i_coffset = i_loffset = 0; //Iterative offsets
	vector myorigin;
	vector myoriginwrk;
	string myspwnfnctn;
	
	if (self.spawnarray_spawn == "spawnarray") {
		remove(self);
		return 0; //no ginception... atleast not yet.
	} else if (self.spawnarray_spawn == "") {
		remove(self);
		return 0; //
	}
	


	
	///////////////////////////////////
	if (self.spawnarray_id) {
		//We have a spawn array id allready, do nothing
	} else {
		//We shall use the public option.
		self.spawnarray_id = lastspawnarrayid + 1;
		lastspawnarrayid = self.spawnarray_id;
	}
	self.spawnarray_id_membertype = 0;
	//pawnarray_id_membertype is 0 for the array itself
	///////////////////////////////////
	myspawnarray_id = self.spawnarray_id;
	myspawnarray_spawnflags = self.spawnflags;
	if (self.spawnarray_sctilesrectify) {
	dospawnarray_sctilesrectify = 1;
	}
	///////////////////////////////////
	
	
	
	
	float snallremself; //Used at the very end of the loops to flag if we will remove the spawned ent
			    //EX: if it is unused or in a forbidden solid etc, and these settings have
			    //been set to disallow such or to trim unused ents along the way
			    //Where it is used, it is set to 0, then the code deciding if the ent
			    //is to be removed is run, then it is set to 1 if so, the ent is removed
			    //and it is set to 0 again
	
	//Do we want to remove unused ents? EX: Skipped ones etc, or unspawned perimiters (or otherwise)
	float saremoveunused;
	float saremoveunusedent;
	entity saremoveunusedenttoremove;
	saremoveunused = 0;
	if (self.spawnarray_removeunused > 1) {
		saremoveunused = 1;
	}
	
	//Here is for checking if we are in forbidden solid etc, atleast the setup for it
	//The idea is not to spawn buildings inside mountains etc
	//This doesn't affect the skips nor the iters
	//Just the main things you are spawning 
	//(EX: the roads will still be spawned)
	////////////////////
	////////////////////
	float snocheckremoveent;
	entity snocheckremoveenttoremove;
	float snocheck;
	float sno_solid;
	float sno_water;
	float sno_lava;
	float sno_slime;
	float sno_sky;
	float sno_area; //X by X area to check
	float sno_arear;//Set if you want the right side to be different
	float sno_up;   //go up and do the same
	float sno_down; //go down and do the same
	float sno_brthld; //block rate threshold (don't need to set)
	float sno_zofset; //z offset
	float sno_trdown; //tracedown
	
	snocheckremoveent = 0;
	sno_solid = 0;
	sno_water = 0;
	sno_lava = 0;
	sno_slime = 0;
	sno_sky = 0;
	sno_area = 0;
	sno_up = 0;
	sno_down = 0;
	sno_brthld = 0;
	sno_zofset = 0;
	sno_trdown = 0;
	
	if (self.spawnarray_spawn_no_solid)
		sno_solid = self.spawnarray_spawn_no_solid;
	
	if (self.spawnarray_spawn_no_water)
		sno_water = self.spawnarray_spawn_no_water;
	
	if (self.spawnarray_spawn_no_lava)
		sno_lava = self.spawnarray_spawn_no_lava;
	
	if (self.spawnarray_spawn_no_slime)
		sno_slime = self.spawnarray_spawn_no_slime;
	
	if (self.spawnarray_spawn_no_sky)
		sno_sky = self.spawnarray_spawn_no_sky;
	
	if (self.spawnarray_spawn_no_brthld)
		sno_brthld = self.spawnarray_spawn_no_brthld;
	
	if (self.spawnarray_spawn_no_zofset)
		sno_zofset = self.spawnarray_spawn_no_zofset;
	
	if (self.spawnarray_spawn_no_trdown)
		sno_trdown = self.spawnarray_spawn_no_trdown;
	
	
	if (sno_solid || sno_water || sno_lava || sno_slime || sno_sky) {
		snocheck = 1;
		
		//I could just assign these, but I just.. don't trust.
		if (self.spawnarray_spawn_no_area)
			sno_area = self.spawnarray_spawn_no_area;
		
		if (self.spawnarray_spawn_no_arear)
			sno_arear = self.spawnarray_spawn_no_arear;
		
		if (self.spawnarray_spawn_no_up)
			sno_up = self.spawnarray_spawn_no_up;
		
		if (self.spawnarray_spawn_no_down)
			sno_down = self.spawnarray_spawn_no_down;
	} else {
		snocheck = 0;
	}
	////////////////////
	//float sn2checkremoveent;
	//entity sn2checkremoveenttoremove;
	float sn2check;
	float sn2_solid;
	float sn2_water;
	float sn2_lava;
	float sn2_slime;
	float sn2_sky;
	float sn2_area; //X by X area to check
	float sn2_arear;//Set if you want the right side to be different
	float sn2_up;   //go up and do the same
	float sn2_down; //go down and do the same
	float sn2_brthld; //block rate threshold (don't need to set)
	float sn2_zofset; //z offset
	float sn2_trdown; //tracedown
	
	//sn2checkremoveent = 0;
	sn2_solid = 0;
	sn2_water = 0;
	sn2_lava = 0;
	sn2_slime = 0;
	sn2_sky = 0;
	sn2_area = 0;
	sn2_up = 0;
	sn2_down = 0;
	sn2_brthld = 0;
	sn2_zofset = 0;
	sn2_trdown = 0;
	
	if (self.spawnarray_spawn_n2_solid)
		sn2_solid = self.spawnarray_spawn_n2_solid;
	
	if (self.spawnarray_spawn_n2_water)
		sn2_water = self.spawnarray_spawn_n2_water;
	
	if (self.spawnarray_spawn_n2_lava)
		sn2_lava = self.spawnarray_spawn_n2_lava;
	
	if (self.spawnarray_spawn_n2_slime)
		sn2_slime = self.spawnarray_spawn_n2_slime;
	
	if (self.spawnarray_spawn_n2_sky)
		sn2_sky = self.spawnarray_spawn_n2_sky;
	
	if (self.spawnarray_spawn_n2_brthld)
		sn2_brthld = self.spawnarray_spawn_n2_brthld;
	
	if (self.spawnarray_spawn_n2_zofset)
		sn2_zofset = self.spawnarray_spawn_n2_zofset;
	
	if (self.spawnarray_spawn_n2_trdown)
		sn2_trdown = self.spawnarray_spawn_n2_trdown;
	
	if (sn2_solid || sn2_water || sn2_lava || sn2_slime || sn2_sky) {
		sn2check = 1;
		
		//I could just assign these, but I just.. don't trust.
		if (self.spawnarray_spawn_n2_area)
			sn2_area = self.spawnarray_spawn_n2_area;
		
		if (self.spawnarray_spawn_n2_arear)
			sn2_arear = self.spawnarray_spawn_n2_arear;
		
		if (self.spawnarray_spawn_n2_up)
			sn2_up = self.spawnarray_spawn_n2_up;
		
		if (self.spawnarray_spawn_n2_down)
			sn2_down = self.spawnarray_spawn_n2_down;
	} else {
		sn2check = 0;
	}
	////////////////////
	//float sn3checkremoveent;
	//entity sn3checkremoveenttoremove;
	float sn3check;
	float sn3_solid;
	float sn3_water;
	float sn3_lava;
	float sn3_slime;
	float sn3_sky;
	float sn3_area; //X by X area to check
	float sn3_arear;//Set if you want the right side to be different
	float sn3_up;   //go up and do the same
	float sn3_down; //go down and do the same
	float sn3_brthld; //block rate threshold (don't need to set)
	float sn3_zofset; //z offset
	float sn3_trdown; //tracedown
	
	//sn3checkremoveent = 0;
	sn3_solid = 0;
	sn3_water = 0;
	sn3_lava = 0;
	sn3_slime = 0;
	sn3_sky = 0;
	sn3_area = 0;
	sn3_up = 0;
	sn3_down = 0;
	sn3_brthld = 0;
	sn3_zofset = 0;
	sn3_trdown = 0;
	
	if (self.spawnarray_spawn_n3_solid)
		sn3_solid = self.spawnarray_spawn_n3_solid;
	
	if (self.spawnarray_spawn_n3_water)
		sn3_water = self.spawnarray_spawn_n3_water;
	
	if (self.spawnarray_spawn_n3_lava)
		sn3_lava = self.spawnarray_spawn_n3_lava;
	
	if (self.spawnarray_spawn_n3_slime)
		sn3_slime = self.spawnarray_spawn_n3_slime;
	
	if (self.spawnarray_spawn_n3_sky)
		sn3_sky = self.spawnarray_spawn_n3_sky;
	
	if (self.spawnarray_spawn_n3_brthld)
		sn3_brthld = self.spawnarray_spawn_n3_brthld;
	
	if (self.spawnarray_spawn_n3_zofset)
		sn3_zofset = self.spawnarray_spawn_n3_zofset;
	
	if (self.spawnarray_spawn_n3_trdown)
		sn3_trdown = self.spawnarray_spawn_n3_trdown;
	
	if (sn3_solid || sn3_water || sn3_lava || sn3_slime || sn3_sky) {
		sn3check = 1;
		
		//I could just assign these, but I just.. don't trust.
		if (self.spawnarray_spawn_n3_area)
			sn3_area = self.spawnarray_spawn_n3_area;
		
		if (self.spawnarray_spawn_n3_arear)
			sn3_arear = self.spawnarray_spawn_n3_arear;
		
		if (self.spawnarray_spawn_n3_up)
			sn3_up = self.spawnarray_spawn_n3_up;
		
		if (self.spawnarray_spawn_n3_down)
			sn3_down = self.spawnarray_spawn_n3_down;
	} else {
		sn3check = 0;
	}
	////////////////////
	////////////////////
	
	
	//For setting some minor variables regarding delay search methods
	float mydelayfindtype = 0;
	if (self.spawnarray_spawn_delaymthdft) {
		mydelayfindtype = self.spawnarray_spawn_delaymthdft;
	} else if (autocvar_g_spawnarray_spawn_delaymthdft_default) {
		mydelayfindtype = autocvar_g_spawnarray_spawn_delaymthdft_default;
	}
	
	
	//Move spawnpoint in absolute terms
	if (self.spawnarray_moveorigin_x
	|| self.spawnarray_moveorigin_y
	|| self.spawnarray_moveorigin_z
	) {
		if (self.spawnarray_moveorigin_x) {
			self.origin_x = self.origin_x + self.spawnarray_moveorigin_x;
		}
		
		if (self.spawnarray_moveorigin_y) {
			self.origin_y = self.origin_y + self.spawnarray_moveorigin_y;
		}
		
		if (self.spawnarray_moveorigin_z) {
			self.origin_z = self.origin_z + self.spawnarray_moveorigin_z;
		}
		
		setorigin (self, self.origin);
	}
	
	//To center a city if you wish, example: used on grid cities spawned from a radial
	if (self.spawnarray_moveorigin_forward
	|| self.spawnarray_moveorigin_right
	|| self.spawnarray_moveorigin_up) {
		local vector myold_v_forward;
		local vector myold_v_right;
		local vector myold_v_up;
		myold_v_forward = v_forward;
		myold_v_right = v_right;
		myold_v_up = v_up;
		
		makevectors(self.angles);
		if (self.spawnarray_moveorigin_forward) {
			self.origin = self.origin + (v_forward * self.spawnarray_moveorigin_forward);
		}
		
		if (self.spawnarray_moveorigin_right) {
			self.origin = self.origin + (v_right * self.spawnarray_moveorigin_right);
		}
		
		if (self.spawnarray_moveorigin_up) {
			self.origin = self.origin + (v_up * self.spawnarray_moveorigin_up);
		}

		setorigin (self, self.origin);
		
		//Reset so we don't conflict with anything else
		v_forward = myold_v_forward;
		v_right = myold_v_right;
		v_up = myold_v_up;
	}
	
	spawnarray_delay_simulated_mintime = 0; //Reset
	spawnarray_delay_simulated_maxtime = 0; //Reset
	
	if (addspawnprefix) {
		myspwnfnctn = strcat("spawnfunc_", self.spawnarray_spawn);
	} else {
		myspwnfnctn = self.spawnarray_spawn;
	}
	myorigin = self.origin;
	
	lvls = self.spawnarray_lvls;
	rows = self.spawnarray_rows;
	cols = self.spawnarray_cols;

	loffset = self.spawnarray_lvl_offset;	
	roffset = self.spawnarray_row_offset;
	coffset = self.spawnarray_col_offset;
	
	perimeteronly = self.spawnarray_perimeteronly;
	perimeteronlyincllvls = self.spawnarray_perimeteronly_lvls;
	
	if (!self.spawnarray_strict)
	{
		if (!lvls) lvls = 1;
		if (!rows) rows = 1;
		if (!cols) cols = 1;
		
		if (self.spawnarray_evaleachoffset) {
			if (!roffset) roffsetee = 1;
			if (!coffset) coffsetee = 1;
			if (!loffset) loffsetee = 1;
		}
		
		if (self.spawnarray_add2offset) {
			if (!self.spawnarray_add2offset_noup)
				myadd2offset_z = self.spawnarray_add2offset;
				
			if (!self.spawnarray_add2offset_nocol)
				myadd2offset_x = self.spawnarray_add2offset;
				
			if (!self.spawnarray_add2offset_norow)
				myadd2offset_y = self.spawnarray_add2offset;
		}

	}
	
	
	
	
	
	//Iterative offsets
		if (self.spawnarray_lvl_ioffset) {
			i_loffset = self.spawnarray_lvl_ioffset;
		}
	
		if (self.spawnarray_row_ioffset) {
			i_roffset = self.spawnarray_row_ioffset;
		}

		if (self.spawnarray_col_ioffset) {
			i_coffset = self.spawnarray_col_ioffset;
		}
	//
	
	//Skips
		if (self.spawnarray_skip_lvls) {
			skp_lvls_cntr = 0 + self.spawnarray_skip_lvls_shift;

			skiplvls = self.spawnarray_skip_lvls;
			if (self.spawnarray_skip_lvls_spawn == "") {
				skiplvls_spwn = 0;
			} else {
				skiplvls_spwn = 1;
				if (addspawnprefix) {
					skiplvls_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_lvls_spawn);
				} else {
					skiplvls_myspwnfnctn = self.spawnarray_skip_lvls_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_lvls_ioffset) {
				skiplvls_ioffset = self.spawnarray_skip_lvls_ioffset;
			}
		}
	
		if (self.spawnarray_skip_rows) {
			skp_rows_cntr = 0 + self.spawnarray_skip_rows_shift;
			
			skiprows = self.spawnarray_skip_rows;
			if (self.spawnarray_skip_rows_spawn == "") {
				skiprows_spwn = 0;
			} else {
				skiprows_spwn = 1;
				if (addspawnprefix) {
					skiprows_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rows_spawn);
				} else {
					skiprows_myspwnfnctn = self.spawnarray_skip_rows_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_rows_ioffset) {
				skiprows_ioffset = self.spawnarray_skip_rows_ioffset;
			}
		}

		if (self.spawnarray_skip_cols) {
			skp_cols_cntr = 0 + self.spawnarray_skip_cols_shift;
			
			skipcols = self.spawnarray_skip_cols;
			if (self.spawnarray_skip_cols_spawn == "") {
				skipcols_spwn = 0;
			} else {
				skipcols_spwn = 1;
				if (addspawnprefix) {
					skipcols_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_cols_spawn);
				} else {
					skipcols_myspwnfnctn = self.spawnarray_skip_cols_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_cols_ioffset) {
				skipcols_ioffset = self.spawnarray_skip_cols_ioffset;
			}
		}
		
		if (self.spawnarray_skip_rows && self.spawnarray_skip_cols) {
			if (self.spawnarray_skip_rc_spawn == "") {
				skiprc_spwn = 0;
			} else {
				skiprc_spwn = 1;
				if (addspawnprefix) {
					skiprc_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rc_spawn);
				} else {
					skiprc_myspwnfnctn = self.spawnarray_skip_rc_spawn;
				}
			}
		}
		
		
		if (self.spawnarray_skip_rows && self.spawnarray_skip_cols && self.spawnarray_skip_lvls) {
			if (self.spawnarray_skip_rcl_spawn == "") {
				skiprcl_spwn = 0;
			} else {
				skiprcl_spwn = 1;
				if (addspawnprefix) {
					skiprcl_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rcl_spawn);
				} else {
					skiprcl_myspwnfnctn = self.spawnarray_skip_rcl_spawn;
				}
			}
		}
	//

	////////////////////////////
	//New row2, col2 stuff
	//
		if (self.spawnarray_skip_rows2) {
			skp_rows2_cntr = 0 + self.spawnarray_skip_rows2_shift;
			
			skiprows2 = self.spawnarray_skip_rows2;
			if (self.spawnarray_skip_rows2_spawn == "") {
				skiprows2_spwn = 0;
			} else {
				skiprows2_spwn = 1;
				if (addspawnprefix) {
					skiprows2_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rows2_spawn);
				} else {
					skiprows2_myspwnfnctn = self.spawnarray_skip_rows2_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_rows2_ioffset) {
				skiprows2_ioffset = self.spawnarray_skip_rows2_ioffset;
			}
		}

		if (self.spawnarray_skip_cols2) {
			skp_cols2_cntr = 0 + self.spawnarray_skip_cols2_shift;
			
			skipcols2 = self.spawnarray_skip_cols2;
			if (self.spawnarray_skip_cols2_spawn == "") {
				skipcols2_spwn = 0;
			} else {
				skipcols2_spwn = 1;
				if (addspawnprefix) {
					skipcols2_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_cols2_spawn);
				} else {
					skipcols2_myspwnfnctn = self.spawnarray_skip_cols2_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_cols2_ioffset) {
				skipcols2_ioffset = self.spawnarray_skip_cols2_ioffset;
			}
		}
		
	//Intersections
		if (self.spawnarray_skip_rows2 && self.spawnarray_skip_cols) {
			if (self.spawnarray_skip_r2c_spawn == "") {
				skipr2c_spwn = 0;
			} else {
				skipr2c_spwn = 1;
				if (addspawnprefix) {
					skipr2c_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r2c_spawn);
				} else {
					skipr2c_myspwnfnctn = self.spawnarray_skip_r2c_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows && self.spawnarray_skip_cols2) {
			if (self.spawnarray_skip_rc2_spawn == "") {
				skiprc2_spwn = 0;
			} else {
				skiprc2_spwn = 1;
				if (addspawnprefix) {
					skiprc2_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rc2_spawn);
				} else {
					skiprc2_myspwnfnctn = self.spawnarray_skip_rc2_spawn;
				}
			}
		}
		
		
		
		if (self.spawnarray_skip_rows2 && self.spawnarray_skip_cols2) {
			if (self.spawnarray_skip_r2c2_spawn == "") {
				skipr2c2_spwn = 0;
			} else {
				skipr2c2_spwn = 1;
				if (addspawnprefix) {
					skipr2c2_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r2c2_spawn);
				} else {
					skipr2c2_myspwnfnctn = self.spawnarray_skip_r2c2_spawn;
				}
			}
		}
		
		
		//Prob won't b used		
		if (self.spawnarray_skip_rows2 && self.spawnarray_skip_cols && self.spawnarray_skip_lvls) {
			if (self.spawnarray_skip_r2cl_spawn == "") {
				skipr2cl_spwn = 0;
			} else {
				skipr2cl_spwn = 1;
				if (addspawnprefix) {
					skipr2cl_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r2cl_spawn);
				} else {
					skipr2cl_myspwnfnctn = self.spawnarray_skip_r2cl_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows && self.spawnarray_skip_cols2 && self.spawnarray_skip_lvls) {
			if (self.spawnarray_skip_rc2l_spawn == "") {
				skiprc2l_spwn = 0;
			} else {
				skiprc2l_spwn = 1;
				if (addspawnprefix) {
					skiprc2l_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rc2l_spawn);
				} else {
					skiprc2l_myspwnfnctn = self.spawnarray_skip_rc2l_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows2 && self.spawnarray_skip_cols2 && self.spawnarray_skip_lvls) {
			if (self.spawnarray_skip_r2c2l_spawn == "") {
				skipr2c2l_spwn = 0;
			} else {
				skipr2c2l_spwn = 1;
				if (addspawnprefix) {
					skipr2c2l_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r2c2l_spawn);
				} else {
					skipr2c2l_myspwnfnctn = self.spawnarray_skip_r2c2l_spawn;
				}
			}
		}
		//But here for completion, to a degree
	//End row2, col2, (with lvl) stuff
	////////////////////////////
	
	////////////////////////////
	//New row3, col3 stuff
	//
		if (self.spawnarray_skip_rows3) {
			skp_rows3_cntr = 0 + self.spawnarray_skip_rows3_shift;
			
			skiprows3 = self.spawnarray_skip_rows3;
			if (self.spawnarray_skip_rows3_spawn == "") {
				skiprows3_spwn = 0;
			} else {
				skiprows3_spwn = 1;
				if (addspawnprefix) {
					skiprows3_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rows3_spawn);
				} else {
					skiprows3_myspwnfnctn = self.spawnarray_skip_rows3_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_rows3_ioffset) {
				skiprows3_ioffset = self.spawnarray_skip_rows3_ioffset;
			}
		}

		if (self.spawnarray_skip_cols3) {
			skp_cols3_cntr = 0 + self.spawnarray_skip_cols3_shift;
			
			skipcols3 = self.spawnarray_skip_cols3;
			if (self.spawnarray_skip_cols3_spawn == "") {
				skipcols3_spwn = 0;
			} else {
				skipcols3_spwn = 1;
				if (addspawnprefix) {
					skipcols3_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_cols3_spawn);
				} else {
					skipcols3_myspwnfnctn = self.spawnarray_skip_cols3_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_cols3_ioffset) {
				skipcols3_ioffset = self.spawnarray_skip_cols3_ioffset;
			}
		}
	// 3 and 1 intersections
		if (self.spawnarray_skip_rows3 && self.spawnarray_skip_cols) {
			if (self.spawnarray_skip_r3c_spawn == "") {
				skipr3c_spwn = 0;
			} else {
				skipr3c_spwn = 1;
				if (addspawnprefix) {
					skipr3c_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r3c_spawn);
				} else {
					skipr3c_myspwnfnctn = self.spawnarray_skip_r3c_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows && self.spawnarray_skip_cols3) {
			if (self.spawnarray_skip_rc3_spawn == "") {
				skiprc3_spwn = 0;
			} else {
				skiprc3_spwn = 1;
				if (addspawnprefix) {
					skiprc3_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rc3_spawn);
				} else {
					skiprc3_myspwnfnctn = self.spawnarray_skip_rc3_spawn;
				}
			}
		}
		
		
		
		if (self.spawnarray_skip_rows3 && self.spawnarray_skip_cols3) {
			if (self.spawnarray_skip_r3c3_spawn == "") {
				skipr3c3_spwn = 0;
			} else {
				skipr3c3_spwn = 1;
				if (addspawnprefix) {
					skipr3c3_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r3c3_spawn);
				} else {
					skipr3c3_myspwnfnctn = self.spawnarray_skip_r3c3_spawn;
				}
			}
		}
		
		//Added for 3 and 2 intersections
		if (self.spawnarray_skip_rows3 && self.spawnarray_skip_cols2) {
			if (self.spawnarray_skip_r3c2_spawn == "") {
				skipr3c2_spwn = 0;
			} else {
				skipr3c2_spwn = 1;
				if (addspawnprefix) {
					skipr3c2_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r3c2_spawn);
				} else {
					skipr3c2_myspwnfnctn = self.spawnarray_skip_r3c2_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows2 && self.spawnarray_skip_cols3) {
			if (self.spawnarray_skip_r2c3_spawn == "") {
				skipr2c3_spwn = 0;
			} else {
				skipr2c3_spwn = 1;
				if (addspawnprefix) {
					skipr2c3_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r2c3_spawn);
				} else {
					skipr2c3_myspwnfnctn = self.spawnarray_skip_r2c3_spawn;
				}
			}
		}
	//End New row3, col3 stuff
	////////////////////////////
	
	////////////////////////////
	//New row4, col4 stuff
	//
		if (self.spawnarray_skip_rows4) {
			skp_rows4_cntr = 0 + self.spawnarray_skip_rows4_shift;
			
			skiprows4 = self.spawnarray_skip_rows4;
			if (self.spawnarray_skip_rows4_spawn == "") {
				skiprows4_spwn = 0;
			} else {
				skiprows4_spwn = 1;
				if (addspawnprefix) {
					skiprows4_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rows4_spawn);
				} else {
					skiprows4_myspwnfnctn = self.spawnarray_skip_rows4_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_rows4_ioffset) {
				skiprows4_ioffset = self.spawnarray_skip_rows4_ioffset;
			}
		}

		if (self.spawnarray_skip_cols4) {
			skp_cols4_cntr = 0 + self.spawnarray_skip_cols4_shift;
			
			skipcols4 = self.spawnarray_skip_cols4;
			if (self.spawnarray_skip_cols4_spawn == "") {
				skipcols4_spwn = 0;
			} else {
				skipcols4_spwn = 1;
				if (addspawnprefix) {
					skipcols4_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_cols4_spawn);
				} else {
					skipcols4_myspwnfnctn = self.spawnarray_skip_cols4_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_cols4_ioffset) {
				skipcols4_ioffset = self.spawnarray_skip_cols4_ioffset;
			}
		}
	// 4 and 1 intersections
		if (self.spawnarray_skip_rows4 && self.spawnarray_skip_cols) {
			if (self.spawnarray_skip_r4c_spawn == "") {
				skipr4c_spwn = 0;
			} else {
				skipr4c_spwn = 1;
				if (addspawnprefix) {
					skipr4c_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r4c_spawn);
				} else {
					skipr4c_myspwnfnctn = self.spawnarray_skip_r4c_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows && self.spawnarray_skip_cols4) {
			if (self.spawnarray_skip_rc4_spawn == "") {
				skiprc4_spwn = 0;
			} else {
				skiprc4_spwn = 1;
				if (addspawnprefix) {
					skiprc4_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rc4_spawn);
				} else {
					skiprc4_myspwnfnctn = self.spawnarray_skip_rc4_spawn;
				}
			}
		}
		
		
		
		if (self.spawnarray_skip_rows4 && self.spawnarray_skip_cols4) {
			if (self.spawnarray_skip_r4c4_spawn == "") {
				skipr4c4_spwn = 0;
			} else {
				skipr4c4_spwn = 1;
				if (addspawnprefix) {
					skipr4c4_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r4c4_spawn);
				} else {
					skipr4c4_myspwnfnctn = self.spawnarray_skip_r4c4_spawn;
				}
			}
		}
		
		//Added for 4 and 2 intersections
		if (self.spawnarray_skip_rows4 && self.spawnarray_skip_cols2) {
			if (self.spawnarray_skip_r4c2_spawn == "") {
				skipr4c2_spwn = 0;
			} else {
				skipr4c2_spwn = 1;
				if (addspawnprefix) {
					skipr4c2_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r4c2_spawn);
				} else {
					skipr4c2_myspwnfnctn = self.spawnarray_skip_r4c2_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows2 && self.spawnarray_skip_cols4) {
			if (self.spawnarray_skip_r2c4_spawn == "") {
				skipr2c4_spwn = 0;
			} else {
				skipr2c4_spwn = 1;
				if (addspawnprefix) {
					skipr2c4_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r2c4_spawn);
				} else {
					skipr2c4_myspwnfnctn = self.spawnarray_skip_r2c4_spawn;
				}
			}
		}
		
		//Added for 4 and 3 intersections
		if (self.spawnarray_skip_rows4 && self.spawnarray_skip_cols3) {
			if (self.spawnarray_skip_r4c3_spawn == "") {
				skipr4c3_spwn = 0;
			} else {
				skipr4c3_spwn = 1;
				if (addspawnprefix) {
					skipr4c3_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r4c3_spawn);
				} else {
					skipr4c3_myspwnfnctn = self.spawnarray_skip_r4c3_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows3 && self.spawnarray_skip_cols4) {
			if (self.spawnarray_skip_r3c4_spawn == "") {
				skipr3c4_spwn = 0;
			} else {
				skipr3c4_spwn = 1;
				if (addspawnprefix) {
					skipr3c4_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r3c4_spawn);
				} else {
					skipr3c4_myspwnfnctn = self.spawnarray_skip_r3c4_spawn;
				}
			}
		}
	//End New row4, col4 stuff
	////////////////////////////
	
	////////////////////////////
	//New row5, col5 stuff
	//
		if (self.spawnarray_skip_rows5) {
			skp_rows5_cntr = 0 + self.spawnarray_skip_rows5_shift;
			
			skiprows5 = self.spawnarray_skip_rows5;
			if (self.spawnarray_skip_rows5_spawn == "") {
				skiprows5_spwn = 0;
			} else {
				skiprows5_spwn = 1;
				if (addspawnprefix) {
					skiprows5_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rows5_spawn);
				} else {
					skiprows5_myspwnfnctn = self.spawnarray_skip_rows5_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_rows5_ioffset) {
				skiprows5_ioffset = self.spawnarray_skip_rows5_ioffset;
			}
		}

		if (self.spawnarray_skip_cols5) {
			skp_cols5_cntr = 0 + self.spawnarray_skip_cols5_shift;
			
			skipcols5 = self.spawnarray_skip_cols5;
			if (self.spawnarray_skip_cols5_spawn == "") {
				skipcols5_spwn = 0;
			} else {
				skipcols5_spwn = 1;
				if (addspawnprefix) {
					skipcols5_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_cols5_spawn);
				} else {
					skipcols5_myspwnfnctn = self.spawnarray_skip_cols5_spawn;
				}
			}
			
			//Use a different iterative offset if set
			if (self.spawnarray_skip_cols5_ioffset) {
				skipcols5_ioffset = self.spawnarray_skip_cols5_ioffset;
			}
		}
	// 5 and 1 intersections
		if (self.spawnarray_skip_rows5 && self.spawnarray_skip_cols) {
			if (self.spawnarray_skip_r5c_spawn == "") {
				skipr5c_spwn = 0;
			} else {
				skipr5c_spwn = 1;
				if (addspawnprefix) {
					skipr5c_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r5c_spawn);
				} else {
					skipr5c_myspwnfnctn = self.spawnarray_skip_r5c_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows && self.spawnarray_skip_cols5) {
			if (self.spawnarray_skip_rc5_spawn == "") {
				skiprc5_spwn = 0;
			} else {
				skiprc5_spwn = 1;
				if (addspawnprefix) {
					skiprc5_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_rc5_spawn);
				} else {
					skiprc5_myspwnfnctn = self.spawnarray_skip_rc5_spawn;
				}
			}
		}
		
		
		
		if (self.spawnarray_skip_rows5 && self.spawnarray_skip_cols5) {
			if (self.spawnarray_skip_r5c5_spawn == "") {
				skipr5c5_spwn = 0;
			} else {
				skipr5c5_spwn = 1;
				if (addspawnprefix) {
					skipr5c5_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r5c5_spawn);
				} else {
					skipr5c5_myspwnfnctn = self.spawnarray_skip_r5c5_spawn;
				}
			}
		}
		
		//Added for 5 and 2 intersections
		if (self.spawnarray_skip_rows5 && self.spawnarray_skip_cols2) {
			if (self.spawnarray_skip_r5c2_spawn == "") {
				skipr5c2_spwn = 0;
			} else {
				skipr5c2_spwn = 1;
				if (addspawnprefix) {
					skipr5c2_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r5c2_spawn);
				} else {
					skipr5c2_myspwnfnctn = self.spawnarray_skip_r5c2_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows2 && self.spawnarray_skip_cols5) {
			if (self.spawnarray_skip_r2c5_spawn == "") {
				skipr2c5_spwn = 0;
			} else {
				skipr2c5_spwn = 1;
				if (addspawnprefix) {
					skipr2c5_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r2c5_spawn);
				} else {
					skipr2c5_myspwnfnctn = self.spawnarray_skip_r2c5_spawn;
				}
			}
		}
		
		//Added for 5 and 3 intersections
		if (self.spawnarray_skip_rows5 && self.spawnarray_skip_cols3) {
			if (self.spawnarray_skip_r5c3_spawn == "") {
				skipr5c3_spwn = 0;
			} else {
				skipr5c3_spwn = 1;
				if (addspawnprefix) {
					skipr5c3_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r5c3_spawn);
				} else {
					skipr5c3_myspwnfnctn = self.spawnarray_skip_r5c3_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows3 && self.spawnarray_skip_cols5) {
			if (self.spawnarray_skip_r3c5_spawn == "") {
				skipr3c5_spwn = 0;
			} else {
				skipr3c5_spwn = 1;
				if (addspawnprefix) {
					skipr3c5_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r3c5_spawn);
				} else {
					skipr3c5_myspwnfnctn = self.spawnarray_skip_r3c5_spawn;
				}
			}
		}
		
		//Added for 5 and 4 intersections
		if (self.spawnarray_skip_rows5 && self.spawnarray_skip_cols4) {
			if (self.spawnarray_skip_r5c4_spawn == "") {
				skipr5c4_spwn = 0;
			} else {
				skipr5c4_spwn = 1;
				if (addspawnprefix) {
					skipr5c4_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r5c4_spawn);
				} else {
					skipr5c4_myspwnfnctn = self.spawnarray_skip_r5c4_spawn;
				}
			}
		}
		
		if (self.spawnarray_skip_rows4 && self.spawnarray_skip_cols5) {
			if (self.spawnarray_skip_r4c5_spawn == "") {
				skipr4c5_spwn = 0;
			} else {
				skipr4c5_spwn = 1;
				if (addspawnprefix) {
					skipr4c5_myspwnfnctn = strcat("spawnfunc_", self.spawnarray_skip_r4c5_spawn);
				} else {
					skipr4c5_myspwnfnctn = self.spawnarray_skip_r4c5_spawn;
				}
			}
		}
	//End New row5, col5 stuff
	////////////////////////////
	
	
	if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("**spawnarray**\n");
	entity myoldspawnself;

	local entity myfirstentity;
	myoldspawnself = self;
	
	if (!myoldspawnself.spawnarray_absolute) {
		makevectorsforspawnarray (myoldspawnself, self);
		
		if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(vtos(v_forward),"v forward\n");
		if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(vtos(v_right),"v right\n");
		if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(vtos(v_up),"v up\n");
		
	}
	
	float doskiplvl, doskiprow, doskipcol;
	float doskiprow2, doskipcol2;
	float doskiprow3, doskipcol3;
	float doskiprow4, doskipcol4;
	float doskiprow5, doskipcol5;
	
	
	//     ///////     //
	//   resumestate   //
	if (myoldspawnself.spawnarray_pauseafterrows) {
		if (myoldspawnself.resumespawnarray) {
			cur_col = myoldspawnself.savedspawnarraycol;
			cur_row = myoldspawnself.savedspawnarrayrow;
			cur_lvl = myoldspawnself.savedspawnarraylvl;
			lastorigin = myoldspawnself.saved_sa_lastorigin;
			if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("SpawnArray Resume State\n");
		}
	}
	//   resumestate   //
	//     ///////     //
	
	
	////////LEVELS////////
	while (cur_lvl < lvls) {
		skp_lvls_cntr++;
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(ftos(cur_lvl),"lvl\n");
		
		doskiplvl = 0;
		
		
		//For skips of levels
		if (skiplvls) {
			if (skp_lvls_cntr >= skiplvls) {
				skp_lvls_cntr = 0;
				doskiplvl = 1;
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("LvlSkip\n");
			} else {
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoRowSkip\n");
			}
		}
		//
		
		
		if (myoldspawnself.spawnarray_absolute) {
			if (i_loffset && !cur_lvl) {
				lastorigin_z = myoldspawnself.origin_z;
				myorigin_z = lastorigin_z;
			} else {
				myorigin_z = myoldspawnself.origin_z + (loffset * cur_lvl);
			}
		} else {
			//
		}
		
		//Iterative offsets
		if (i_loffset) {
			if (cur_lvl) {
				local float myiloffset;
					
				if (doskiplvl && skiplvls_ioffset) {
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("L-IOFFSET set for skiplvls\n");
					myiloffset = skiplvls_ioffset;
				} else {
					myiloffset = i_loffset;
				}
						
				if (myoldspawnself.spawnarray_absolute) {
					//Not implementing skiplvls_ioffset for absolute yet
					lastorigin_z = lastorigin_z + i_loffset;
					myorigin_z = lastorigin_z;
				} else {
					//Normal
					lastorigin = lastorigin + (v_up * ((myiloffset + myadd2offset_z)));
				}
			}
		}
		//
		lastlvlorigin = lastorigin; //For iterative offsets;
		
		////////ROWS////////
		while (cur_row < rows) {
			skp_rows_cntr++;
			skp_rows2_cntr++;
			skp_rows3_cntr++;
			skp_rows4_cntr++;
			skp_rows5_cntr++;
			if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(ftos(cur_row),"row\n");
			
			
			//For skips of rows
			doskiprow = 0;
			if (skiprows) {
				if (skp_rows_cntr >= skiprows) {
					skp_rows_cntr = 0;
					doskiprow = 1;
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("RowSkip\n");
				} else {
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoRowSkip\n");
				}
			}
			//
			
			//
			doskiprow2 = 0;
			if (skiprows2) {
				if (skp_rows2_cntr >= skiprows2) {
					skp_rows2_cntr = 0;
					doskiprow2 = 1;
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("RowSkip2\n");
				} else {
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoRowSkip2\n");
				}
			}
			//
			
			//
			doskiprow3 = 0;
			if (skiprows3) {
				if (skp_rows3_cntr >= skiprows3) {
					skp_rows3_cntr = 0;
					doskiprow3 = 1;
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("RowSkip3\n");
				} else {
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoRowSkip3\n");
				}
			}
			//
			
			//
			doskiprow4 = 0;
			if (skiprows4) {
				if (skp_rows4_cntr >= skiprows4) {
					skp_rows4_cntr = 0;
					doskiprow4 = 1;
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("RowSkip4\n");
				} else {
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoRowSkip4\n");
				}
			}
			//
			
			//
			doskiprow5 = 0;
			if (skiprows5) {
				if (skp_rows5_cntr >= skiprows5) {
					skp_rows5_cntr = 0;
					doskiprow5 = 1;
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("RowSkip5\n");
				} else {
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoRowSkip5\n");
				}
			}
			//
			 
			 
			 
			 
			if (myoldspawnself.spawnarray_absolute) {
				if (i_roffset && !cur_row) {
					lastorigin_y = myoldspawnself.origin_y; 
					myorigin_y = lastorigin_y;
				} else {
					myorigin_y = myoldspawnself.origin_y + (roffset * cur_row);
				}
			} else {
				//
			}
			
			
			//Iterative offsets
			if (i_roffset) {
				if (cur_row) {
					local float myiroffset;
					
					//3 and 2 take precedence
					if (doskiprow5 && skiprows5_ioffset) {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("R-IOFFSET set for skiprows5\n");
						myiroffset = skiprows5_ioffset;
					} else if (doskiprow4 && skiprows4_ioffset) {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("R-IOFFSET set for skiprows4\n");
						myiroffset = skiprows4_ioffset;
					} else if (doskiprow3 && skiprows3_ioffset) {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("R-IOFFSET set for skiprows3\n");
						myiroffset = skiprows3_ioffset;
					} else if (doskiprow2 && skiprows2_ioffset) {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("R-IOFFSET set for skiprows2\n");
						myiroffset = skiprows2_ioffset;
					} else if (doskiprow && skiprows_ioffset) {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("R-IOFFSET set for skiprows\n");
						myiroffset = skiprows_ioffset;
					} else {
						myiroffset = i_roffset;
					}
						
				
					if (myoldspawnself.spawnarray_absolute) {
						//Not implementing skiprows_ioffset for absolute yet
						lastorigin_y = lastorigin_y + i_roffset;
						myorigin_y = lastorigin_y;
					} else {
						//Normal
						lastorigin = lastorigin + (v_right * ((myiroffset + myadd2offset_y)));
					}
				}
			}
			//
			lastroworigin = lastorigin; //For iterative offsets;
			
			
			////////COLUMNS////////
			while (cur_col < cols) {
				skp_cols_cntr++;
				skp_cols2_cntr++;
				skp_cols3_cntr++;
				skp_cols4_cntr++;
				skp_cols5_cntr++;
				if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(ftos(cur_col),"col\n");
				
				
				//For skips of columns
				doskipcol = 0;
				if (skipcols) {
					if (skp_cols_cntr >= skipcols) {
						skp_cols_cntr = 0;
						doskipcol = 1;
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("SkipColumn\n");
					} else {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoSkipColumn\n");
					}
				}
				//
				
				doskipcol2 = 0;
				if (skipcols2) {
					if (skp_cols2_cntr >= skipcols2) {
						skp_cols2_cntr = 0;
						doskipcol2 = 1;
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("SkipColumn2\n");
					} else {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoSkipColumn2\n");
					}
				}
				//
				
				doskipcol3 = 0;
				if (skipcols3) {
					if (skp_cols3_cntr >= skipcols3) {
						skp_cols3_cntr = 0;
						doskipcol3 = 1;
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("SkipColumn3\n");
					} else {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoSkipColumn3\n");
					}
				}
				//
				
				doskipcol4 = 0;
				if (skipcols4) {
					if (skp_cols4_cntr >= skipcols4) {
						skp_cols4_cntr = 0;
						doskipcol4 = 1;
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("SkipColumn4\n");
					} else {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoSkipColumn4\n");
					}
				}
				//
				
				doskipcol5 = 0;
				if (skipcols5) {
					if (skp_cols5_cntr >= skipcols5) {
						skp_cols5_cntr = 0;
						doskipcol5 = 1;
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("SkipColumn5\n");
					} else {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("NoSkipColumn5\n");
					}
				}
				//
				
				
				if (myoldspawnself.spawnarray_absolute) {
					if (i_coffset && !cur_col) {
						lastorigin_x = myoldspawnself.origin_x; 
						myorigin_x = lastorigin_x;
					} else {
						myorigin_x = myoldspawnself.origin_x + (coffset * cur_col);
					}
				} else {
					myorigin = myoldspawnself.origin
					+ (v_up * ((loffset + myadd2offset_z) * cur_lvl))
					+ (v_right * ((roffset + myadd2offset_y) * cur_row))
					+ (v_forward * ((coffset + myadd2offset_x) * cur_col));
				}
				
				//Iterative offset
				if (i_coffset) {
					if (cur_col) {
						local float myicoffset;
						
						//5 ... 3 then 2 takes precedence
						if (doskipcol5 && skipcols5_ioffset) {
							if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("IOFFSET set for skipcols5\n");
							myicoffset = skipcols5_ioffset;
						} else if (doskipcol4 && skipcols4_ioffset) {
							if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("IOFFSET set for skipcols4\n");
							myicoffset = skipcols4_ioffset;
						} else if (doskipcol3 && skipcols3_ioffset) {
							if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("IOFFSET set for skipcols3\n");
							myicoffset = skipcols3_ioffset;
						} else if (doskipcol2 && skipcols2_ioffset) {
							if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("IOFFSET set for skipcols2\n");
							myicoffset = skipcols2_ioffset;
						} else if (doskipcol && skipcols_ioffset) {
							if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("IOFFSET set for skipcols\n");
							myicoffset = skipcols_ioffset;
						} else {
							myicoffset = i_coffset;
						}
						
						if (myoldspawnself.spawnarray_absolute) {
							//Not implementing skipcols_ioffset for absolute yet
							lastorigin_x = lastorigin_x + i_coffset;
							myorigin_x = lastorigin_x;
						} else {
							//Normal
							lastorigin = lastorigin  + (v_forward * ((myicoffset + myadd2offset_x)));
						}
					}
				}
				//Use iterative offset
				if not(myoldspawnself.spawnarray_absolute) {
					if (i_coffset || i_roffset || i_loffset) {
						if ((i_coffset || cols <= 1)
						&& (i_roffset || rows <= 1)
						&& (i_loffset || lvls <= 1)) {
							myorigin = myoldspawnself.origin + lastorigin;
							
							//We need to adjust the origin if we have changed the offset for a skip
							if (doskipcol5 && skipcols5_ioffset && !myoldspawnself.spawnarray_skip_cols5_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting IOFFSET set for skipcols5\n");
								myorigin = myorigin + (v_forward * ((i_coffset - skipcols5_ioffset)*0.5));
							} else if (doskipcol4 && skipcols4_ioffset && !myoldspawnself.spawnarray_skip_cols4_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting IOFFSET set for skipcols4\n");
								myorigin = myorigin + (v_forward * ((i_coffset - skipcols4_ioffset)*0.5));
							} else if (doskipcol3 && skipcols3_ioffset && !myoldspawnself.spawnarray_skip_cols3_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting IOFFSET set for skipcols3\n");
								myorigin = myorigin + (v_forward * ((i_coffset - skipcols3_ioffset)*0.5));
							} else if (doskipcol2 && skipcols2_ioffset && !myoldspawnself.spawnarray_skip_cols2_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting IOFFSET set for skipcols2\n");
								myorigin = myorigin + (v_forward * ((i_coffset - skipcols2_ioffset)*0.5));
							} else if (doskipcol && skipcols_ioffset && !myoldspawnself.spawnarray_skip_cols_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting IOFFSET set for skipcols\n");
								myorigin = myorigin + (v_forward * ((i_coffset - skipcols_ioffset)*0.5));
							}
							
							if (doskiprow5 && skiprows5_ioffset && !myoldspawnself.spawnarray_skip_rows5_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting R-IOFFSET set for skiprows5\n");
								myorigin = myorigin + (v_right * ((i_roffset - skiprows5_ioffset)*0.5));
							} else if (doskiprow4 && skiprows4_ioffset && !myoldspawnself.spawnarray_skip_rows4_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting R-IOFFSET set for skiprows4\n");
								myorigin = myorigin + (v_right * ((i_roffset - skiprows4_ioffset)*0.5));
							} else if (doskiprow3 && skiprows3_ioffset && !myoldspawnself.spawnarray_skip_rows3_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting R-IOFFSET set for skiprows3\n");
								myorigin = myorigin + (v_right * ((i_roffset - skiprows3_ioffset)*0.5));
							} else if (doskiprow2 && skiprows2_ioffset && !myoldspawnself.spawnarray_skip_rows2_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting R-IOFFSET set for skiprows2\n");
								myorigin = myorigin + (v_right * ((i_roffset - skiprows2_ioffset)*0.5));
							} else if (doskiprow && skiprows_ioffset && !myoldspawnself.spawnarray_skip_rows_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting R-IOFFSET set for skiprows\n");
								myorigin = myorigin + (v_right * ((i_roffset - skiprows_ioffset)*0.5));
							}
							
							if (doskiplvl && skiplvls_ioffset && !myoldspawnself.spawnarray_skip_lvls_noadjust) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("Adjusting L-IOFFSET set for skiplvls\n");
								myorigin = myorigin + (v_up * ((i_loffset - skiplvls_ioffset)*0.5));
							}
						}
					}
				}
				//
				
				myfirstentity = spawn();

				copyentity(myoldspawnself, myfirstentity);
	
				self = myfirstentity;
	
				////self.spawnarray_func(); //Doing it another way
				self.classname = strzone(myoldspawnself.spawnarray_spawn);
				self.origin = myorigin;
				
				//print(myspwnfnctn,"-\n");
				//print(ftos(isfunction(myspwnfnctn)),"-\n");
				
					
					//////////////////////////////////////////////////////////
					//////Some Special handling if you want it
					//////Made for the SC_Tiles buildings
					if (myoldspawnself.spawnarray_sctilesspecial) {
						
						
						if (self.abdbld_baseheight_sc
						|| self.abdbld_baseheightrand_sc
						|| self.abdbld_baseheightrandmax_sc) {
							//Do nothing
						} else {
							//Move by random amount of 1.5qu: less zfight
							self.abdbld_baseheightrand_sc = 1;
							self.abdbld_baseheightrandmax_sc = 1.5;
						}
						
						//Some jitter to avoid some zfighting
						//(note this could cause some bboxes to be slightly where not wanted though)
						self.origin_x = self.origin_x + ((random() * 1.5) - 0.75);
						self.origin_y = self.origin_y + ((random() * 1.5) - 0.75);
					}
					//////Some Special handling if you want it
					//////////////////////////////////////////////////////////
					
					
				
				if(myoldspawnself.spawnarray_droptofloor) {
					droptofloor();
				}
				
				///////////////////////////////////
				//Set ID now:
				self.spawnarray_id_lvl = cur_lvl;
				self.spawnarray_id_row = cur_row;
				self.spawnarray_id_col = cur_col;
				///////////////////////////////////
				self.spawnarray_id_membertype = 1;
				self.spawnarray_id_generation = myoldspawnself.spawnarray_id_generation + 1;
				///////////////////////////////////
				
				if(self.spawnarray_iter >= 1) {
					  iterskipcounter++;
					  if ((self.spawnarray_iter_skipuntil > 0) && iterskipcounter < self.spawnarray_iter_skipuntil) {
					  	//Do nothing
						if(self.spawnarray_iter_and) {
							if (self.spawnarray_iter_andobeyskip) {
								//Do nothing
							} else if(isfunction(myspwnfnctn)) {
								if (myoldspawnself.spawnarray_spawn_delay || myoldspawnself.spawnarray_spawn_delayjitter) {
									spawnarraydelay(myoldspawnself.spawnarray_spawn_delaymethod, self, myspwnfnctn, myoldspawnself.spawnarray_spawn_delay, myoldspawnself.spawnarray_spawn_delayjitter);
								} else {
									callfunction(myspwnfnctn);
								}
							}
						}
					  } else {
					  	if(self.spawnarray_iter_skipuntil) {
							iterskipcounter = 0;
						}
						
						local entity myiteroldself;
						local entity myiterandentity;
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(ftos(self.spawnarray_iter)," doing iter, spawnarray\n");
						self.spawnarray_iter = self.spawnarray_iter - 1;
						
						if((self.spawnarray_iter_and) &&
						(!(self.spawnarray_iter_skipuntil && self.spawnarray_iter_andxorskip))
						)
						{
							myiteroldself = self;
							myiterandentity = spawn();
							copyentity(self, myiterandentity);
							myiterandentity.spawnarray_iter = 0;
						}
	
						//ita apply
						if (self.spawnarray_iter_revitmita >= 1) {
							spawnarray_ita_apply(); //Reversed affinity
							spawnarray_itm_apply();
						} else {
						spawnarray_itm_apply(); //Multipliers are first
						spawnarray_ita_apply(); //Then additions
						}
						
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(ftos(self.spawnarray_rows), "x", ftos(self.spawnarray_cols), " ROWS x COLS!!!\n\n");
						
						spawnfunc_spawnarray();
						
						if((self.spawnarray_iter_and && myiterandentity && myiteroldself) &&
						(!(self.spawnarray_iter_skipuntil && self.spawnarray_iter_andxorskip))
						)
						{
							self = myiterandentity;
							
							if(isfunction(myspwnfnctn)) {
								if (myoldspawnself.spawnarray_spawn_delay || myoldspawnself.spawnarray_spawn_delayjitter) {
									spawnarraydelay(myoldspawnself.spawnarray_spawn_delaymethod, self, myspwnfnctn, myoldspawnself.spawnarray_spawn_delay, myoldspawnself.spawnarray_spawn_delayjitter);
								} else {
									callfunction(myspwnfnctn);
								}
							}
							
							self = myiteroldself;
						}
					  }
				} else {
					local float snocheck1allows;
					local float snocheck2allows;
					local float snocheck3allows;
					if (!snocheck || 
						spawnarrayspawnno_allowspawn(
						self,
						sno_brthld,
						sno_zofset,
						sno_trdown,
						sno_area,
						sno_arear, 
						sno_up,
						sno_down,
						sno_solid, 
						sno_water, 
						sno_lava,
						sno_slime,
						sno_sky, 1))
					{
						snocheck1allows = 1;
					} else {
						snocheck1allows = 0;
					}
						
						
					if (!sn2check || 
						spawnarrayspawnno_allowspawn(
						self,
						sn2_brthld,
						sn2_zofset,
						sn2_trdown,
						sn2_area,
						sn2_arear, 
						sn2_up,
						sn2_down,
						sn2_solid, 
						sn2_water, 
						sn2_lava,
						sn2_slime,
						sn2_sky, 1))
						{
						snocheck2allows = 1;
					} else {
						snocheck2allows = 0;
					}
						
						
					if (!sn3check || 
						spawnarrayspawnno_allowspawn(
						self,
						sn3_brthld,
						sn3_zofset,
						sn3_trdown,
						sn3_area,
						sn3_arear, 
						sn3_up,
						sn3_down,
						sn3_solid, 
						sn3_water, 
						sn3_lava,
						sn3_slime,
						sn3_sky, 1))
						{
						snocheck3allows = 1;
					} else {
						snocheck3allows = 0;
					}
					
				
					local float doskipforperi;
					doskipforperi = 0;
					
					//Perimeter only?
					if (perimeteronly) {
						doskipforperi = 1;
						if (!cur_row) {
							//No skip
							doskipforperi = 0;
						} else if (cur_row >= (rows - 1)) {
							//No skip
							doskipforperi = 0;
						} else if (!cur_col) {
							//No skip
							doskipforperi = 0;
						} else if (cur_col >= (cols - 1)) {
							//No skip
							doskipforperi = 0;
						} else if (perimeteronlyincllvls && (!cur_lvl)) {
							//No skip
							doskipforperi = 0;	
						} else if (perimeteronlyincllvls && (cur_lvl >= (lvls - 1))) {
							//No skip
							doskipforperi = 0;
						}
					}
					
					if (doskipforperi == 1) {
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("peri\n");
						//Do nothing
						
						if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					////////////////////
					//Note: Skip5 omits lvl, thus is up here
					//so that it will have precedence over a lower-order
					//intersection even when that intersection is a 3 way (xyz)
					} else if (doskiprow5 && doskipcol5) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr5c5_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r5c5_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r5c5_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r5c5_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr5c5_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r5c5_rotate;
								callfunction(skipr5c5_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 5 and 4
					} else if (doskiprow5 && doskipcol4) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr5c4_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r5c4_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r5c4_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r5c4_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr5c4_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r5c4_rotate;
								callfunction(skipr5c4_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow4 && doskipcol5) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr4c5_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r4c5_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r4c5_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r4c5_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr4c5_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r4c5_rotate;
								callfunction(skipr4c5_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 5 and 3
					} else if (doskiprow5 && doskipcol3) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr5c3_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r5c3_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r5c3_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r5c3_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr5c3_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r5c3_rotate;
								callfunction(skipr5c3_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow3 && doskipcol5) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr3c5_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r3c5_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r3c5_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r3c5_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr3c5_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r3c5_rotate;
								callfunction(skipr3c5_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 5 and 2
					} else if (doskiprow5 && doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr5c2_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r5c2_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r5c2_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r5c2_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr5c2_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r5c2_rotate;
								callfunction(skipr5c2_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow2 && doskipcol5) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr2c5_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r2c5_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r2c5_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r2c5_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr2c5_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r2c5_rotate;
								callfunction(skipr2c5_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 5 and 1
					} else if (doskiprow5 && doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr5c_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r5c_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r5c_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r5c_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr5c_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r5c_rotate;
								callfunction(skipr5c_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow && doskipcol5) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprc5_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rc5_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rc5_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rc5_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprc5_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rc5_rotate;
								callfunction(skiprc5_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					////////////////////
					////////////////////
					//Note: Skip4 omits lvl, thus is up here
					//so that it will have precedence over a lower-order
					//intersection even when that intersection is a 3 way (xyz)
					} else if (doskiprow4 && doskipcol4) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr4c4_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r4c4_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r4c4_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r4c4_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr4c4_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r4c4_rotate;
								callfunction(skipr4c4_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 4 and 3
					} else if (doskiprow4 && doskipcol3) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr4c3_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r4c3_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r4c3_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r4c3_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr4c3_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r4c3_rotate;
								callfunction(skipr4c3_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow3 && doskipcol4) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr3c4_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r3c4_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r3c4_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r3c4_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr3c4_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r3c4_rotate;
								callfunction(skipr3c4_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 4 and 2
					} else if (doskiprow4 && doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr4c2_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r4c2_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r4c2_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r4c2_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr4c2_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r4c2_rotate;
								callfunction(skipr4c2_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow2 && doskipcol4) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr2c4_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r2c4_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r2c4_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r2c4_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr2c4_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r2c4_rotate;
								callfunction(skipr2c4_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 4 and 1
					} else if (doskiprow4 && doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr4c_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r4c_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r4c_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r4c_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr4c_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r4c_rotate;
								callfunction(skipr4c_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow && doskipcol4) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprc4_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rc4_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rc4_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rc4_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprc4_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rc4_rotate;
								callfunction(skiprc4_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					////////////////////
					////////////////////
					//Note: Skip3 omits lvl, thus is up here
					//so that it will have precedence over a lower-order
					//intersection even when that intersection is a 3 way (xyz)
					} else if (doskiprow3 && doskipcol3) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr3c3_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r3c3_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r3c3_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r3c3_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr3c3_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r3c3_rotate;
								callfunction(skipr3c3_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					
					//Intersections between 3 and 2
					} else if (doskiprow3 && doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr3c2_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r3c2_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r3c2_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r3c2_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr3c2_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r3c2_rotate;
								callfunction(skipr3c2_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow2 && doskipcol3) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr2c3_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r2c3_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r2c3_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r2c3_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr2c3_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r2c3_rotate;
								callfunction(skipr2c3_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//Intersections between 3 and 1
					} else if (doskiprow3 && doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr3c_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r3c_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r3c_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r3c_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr3c_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r3c_rotate;
								callfunction(skipr3c_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow && doskipcol3) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprc3_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rc3_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rc3_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rc3_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprc3_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rc3_rotate;
								callfunction(skiprc3_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					////////////////////
					//Row2. Col2 and lvl
					//This will rarely be used:
					} else if (doskiplvl && doskiprow2 && doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr2c2l_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r2c2l_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r2c2l_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r2c2l_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr2c2l_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r2c2l_rotate;
								callfunction(skipr2c2l_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiplvl && doskiprow2 && doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr2cl_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r2cl_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r2cl_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r2cl_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr2cl_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r2cl_rotate;
								callfunction(skipr2cl_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiplvl && doskiprow && doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprc2l_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rc2l_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rc2l_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rc2l_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprc2l_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rc2l_rotate;
								callfunction(skiprc2l_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiplvl && doskiprow && doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprcl_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rcl_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rcl_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rcl_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprcl_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rcl_rotate;
								callfunction(skiprcl_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiprow2 && doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr2c2_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r2c2_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r2c2_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r2c2_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr2c2_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r2c2_rotate;
								callfunction(skipr2c2_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow2 && doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipr2c_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_r2c_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_r2c_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_r2c_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipr2c_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_r2c_rotate;
								callfunction(skipr2c_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiprow && doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprc2_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rc2_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rc2_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rc2_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprc2_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rc2_rotate;
								callfunction(skiprc2_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiprow && doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprc_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rc_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rc_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rc_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprc_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rc_rotate;
								callfunction(skiprc_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskiplvl) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiplvls_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_lvls_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_lvls_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_lvls_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiplvls_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_lvls_rotate;
								callfunction(skiplvls_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiprow5) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprows5_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rows5_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rows5_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rows5_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprows5_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rows5_rotate;
								callfunction(skiprows5_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskipcol5) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipcols5_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_cols5_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_cols5_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_cols5_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipcols5_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_cols5_rotate;
								callfunction(skipcols5_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiprow4) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprows4_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rows4_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rows4_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rows4_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprows4_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rows4_rotate;
								callfunction(skiprows4_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskipcol4) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipcols4_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_cols4_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_cols4_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_cols4_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipcols4_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_cols4_rotate;
								callfunction(skipcols4_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiprow3) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprows3_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rows3_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rows3_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rows3_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprows3_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rows3_rotate;
								callfunction(skiprows3_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskipcol3) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipcols3_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_cols3_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_cols3_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_cols3_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipcols3_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_cols3_rotate;
								callfunction(skipcols3_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiprow2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprows2_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rows2_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rows2_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rows2_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprows2_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rows2_rotate;
								callfunction(skiprows2_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskipcol2) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipcols2_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_cols2_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_cols2_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_cols2_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipcols2_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_cols2_rotate;
								callfunction(skipcols2_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					//
					} else if (doskiprow) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skiprows_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_rows_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_rows_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_rows_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skiprows_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_rows_rotate;
								callfunction(skiprows_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if (doskipcol) {
						self.spawnarray_id_membertype = 2; //to tell the rectify procedures that this is a skip
						if (skipcols_spwn) {
							if ((!snocheck1allows && myoldspawnself.spawnarray_skip_cols_sno)
							|| (!snocheck3allows && myoldspawnself.spawnarray_skip_cols_sn3)
							|| (!snocheck2allows && myoldspawnself.spawnarray_skip_cols_sn2)) {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							} else if(isfunction(skipcols_myspwnfnctn)) {
								self.angles_y = self.angles_y + myoldspawnself.spawnarray_skip_cols_rotate;
								callfunction(skipcols_myspwnfnctn);
							}
						} else if (saremoveunused) {
							saremoveunusedent = 1;
							saremoveunusedenttoremove = self;
						}
					} else if(isfunction(myspwnfnctn)) {
						self.spawnarray_id_membertype = 1; //The normal spawn
						if ((snocheck1allows || myoldspawnself.spawnarray_spawn_no_nomain)
						&& (snocheck3allows || myoldspawnself.spawnarray_spawn_n3_nomain)
						&& (snocheck2allows || myoldspawnself.spawnarray_spawn_n2_nomain)) {
							if (myoldspawnself.spawnarray_spawn_delay || myoldspawnself.spawnarray_spawn_delayjitter) {
								spawnarraydelay(myoldspawnself.spawnarray_spawn_delaymethod, self, myspwnfnctn, myoldspawnself.spawnarray_spawn_delay, myoldspawnself.spawnarray_spawn_delayjitter);
							} else {
							callfunction(myspwnfnctn);
							}
						} else {
							snocheckremoveent = 1;
							snocheckremoveenttoremove = self;
						}
					}
				}
				
				if (!hasspawnedone || myoldspawnself.spawnarray_evaleachoffset) {
					if (!myoldspawnself.spawnarray_strict)
					{
					
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(vtos(self.absmin),"\n");
						if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(vtos(self.absmax),"\n");
						if (!roffset || roffsetee) roffset = (self.absmax_y - self.absmin_y);
						if (!coffset || coffsetee) coffset = (self.absmax_x - self.absmin_x);
						if (!loffset || loffsetee) loffset = (self.absmax_z - self.absmin_z);
					}
					hasspawnedone = 1;
				}

				if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print(self.classname, " My classname\n");
				
				/////////////////////////////////////
				/////////////////////////////////////
				/////////Remove unused ent///////////
				snallremself = 0; //Do we remove?
				
				if (snocheckremoveent) {
					if (snocheckremoveenttoremove == self) {
						if (self != world) {
							if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("setting to removing snochecked ent", etos(self), "\n");
							
							snallremself = 1;
							snocheckremoveenttoremove = world;
						}
					}
					snocheckremoveent = 0;
				}
				
				if (saremoveunusedent) {
					if (saremoveunusedenttoremove == self) {
						if (self != world) {
							if (snallremself) {
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("unused ent", etos(self), "allready snocheckremoved\n");	
							} else {
								snallremself = 1;
								if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("removing unused ent", etos(self), "\n");
							}
							saremoveunusedenttoremove = world;
						}
					}
					saremoveunusedent = 0;
				}
				
				if (snallremself) {
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("removing ent", etos(self), "\n");
					remove(self);
				}
				
				snallremself = 0;
				/////////Remove unused ent///////////
				/////////////////////////////////////
				/////////////////////////////////////
				
			cur_col++;
			}
			////////END COLUMNS////////
			
			cur_col = 0; //Reset
			skp_cols_cntr = 0 + myoldspawnself.spawnarray_skip_cols_shift;
			skp_cols2_cntr = 0 + myoldspawnself.spawnarray_skip_cols2_shift;
			skp_cols3_cntr = 0 + myoldspawnself.spawnarray_skip_cols3_shift;
			skp_cols4_cntr = 0 + myoldspawnself.spawnarray_skip_cols4_shift;
			skp_cols5_cntr = 0 + myoldspawnself.spawnarray_skip_cols5_shift;
			lastorigin = lastroworigin; //Reset for iterative offsets
			
			
			if(myoldspawnself.spawnarray_iter_suresetrow < 0) {
				iterskipcounter = iterskipcounter + (myoldspawnself.spawnarray_iter_suresetrow * -1);
			} else if(myoldspawnself.spawnarray_iter_suresetrow) {
				iterskipcounter = 0;
			}
		
		cur_row++;
		//      ///////////////////      //
		//	//saving state   //      //
		//      ///////////////////      //
			if (myoldspawnself.spawnarray_pauseafterrows) {
				if ((cur_row - myoldspawnself.savedspawnarrayrow) == myoldspawnself.spawnarray_pauseafterrows) {
					myoldspawnself.savedspawnarraycol = cur_col;
					myoldspawnself.savedspawnarrayrow = cur_row;
					myoldspawnself.savedspawnarraylvl = cur_lvl;
					myoldspawnself.resumespawnarray = 1;
					myoldspawnself.saved_sa_lastorigin = lastorigin;
					doresumespawnarray = 1;
					
					if (autocvar_sv_spawnarraysctilesrectify_noprint < 3) print("SpawnArray SAVE State\n");
					
					cur_col = cols + 10000;
					cur_row = rows + 10000;
					cur_lvl = lvls + 10000;
				}
			}
		//      ///////////////////      //
		//	//saving state   //      //
		//      ///////////////////      //
		}
		////////ENDROWS////////
		
		cur_row = 0; //Reset
		skp_rows_cntr = 0 + myoldspawnself.spawnarray_skip_rows_shift;
		skp_rows2_cntr = 0 + myoldspawnself.spawnarray_skip_rows2_shift;
		skp_rows3_cntr = 0 + myoldspawnself.spawnarray_skip_rows3_shift;
		skp_rows4_cntr = 0 + myoldspawnself.spawnarray_skip_rows4_shift;
		skp_rows5_cntr = 0 + myoldspawnself.spawnarray_skip_rows5_shift;
		lastorigin = lastlvlorigin; //Reset for iterative offsets
		
		if(myoldspawnself.spawnarray_iter_suresetlvl < 0) {
			iterskipcounter = iterskipcounter + (myoldspawnself.spawnarray_iter_suresetlvl * -1);
		} else if(myoldspawnself.spawnarray_iter_suresetlvl) {
			iterskipcounter = 0;
		}
		 
		if (!myoldspawnself.spawnarray_absolute) {
			//This is for the lvl add angle function
			//(Which for each lvl adds to the angle, to make a column that spins)
			
			//Should we makevectors again?
			local float myvecsmake;
			myvecsmake = 0;
			if (myoldspawnself.spawnarray_lvl_addangle) {
				myoldspawnself.angles_y = myoldspawnself.angles_y + myoldspawnself.spawnarray_lvl_addangle;
				myvecsmake = 1;
			}
	
			if (myoldspawnself.spawnarray_lvl_addangles_x
			|| myoldspawnself.spawnarray_lvl_addangles_y
			|| myoldspawnself.spawnarray_lvl_addangles_z) {
				myoldspawnself.angles_x = myoldspawnself.angles_x + myoldspawnself.spawnarray_lvl_addangles_x;
				myoldspawnself.angles_y = myoldspawnself.angles_y + myoldspawnself.spawnarray_lvl_addangles_y;
				myoldspawnself.angles_z = myoldspawnself.angles_z + myoldspawnself.spawnarray_lvl_addangles_z;
				myvecsmake = 1;
			}
	
			if (myvecsmake) {
				makevectorsforspawnarray(myoldspawnself, myoldspawnself);
			}
		}	
		
	
	cur_lvl++;
	}
	////////LEVELS////////

	self = myoldspawnself;
	
	if (doresumespawnarray) {
		if (addspawnprefix) {
			self.think = spawnfunc_spawnarray;
		} else {
			self.think = do_spawnarray;
		}
		
		self.nextthink = time + self.spawnarray_pauseafterrowstime;
	} else {
		if (dospawnarray_sctilesrectify) {
			if (spawnarray_delay_simulated_maxtime) {
				//We don't rectify here for this type, instead it's done in a block later
			} else {
				//If we are doing the other two delay methods
				local entity sctilesrectifyent;
				local float mydelayforrectify;
				mydelayforrectify = (myoldspawnself.spawnarray_spawn_delay
				+ myoldspawnself.spawnarray_spawn_delayjitter
				+ 0.1);
			
				sctilesrectifyent = spawn();
			
				spawnarraysctilesrectifyafterdelay(myspawnarray_id, myspawnarray_spawnflags, sctilesrectifyent, mydelayforrectify, 0.5);
			}	
		}
		remove(self);
	}
	
	//Here, once we are done, we simulate the spawndelays 
	//To create a varied spawn field, if called for
	if (spawnarray_delay_simulated_maxtime) {
		spawnarraydelaymethod3_do(0.1, mydelayfindtype); //The delayfindtype is only evaluated for method3
		if (dospawnarray_sctilesrectify) {
			if (doresumespawnarray) {
				// Do nothing, we only want to rectify at the end.
			} else {
				spawnarray_rectifysctileslargebuildings(myspawnarray_id, myspawnarray_spawnflags);
			}
		}
	}
	
	return 1;
}


void spawnfunc_spawnarray (void) {
	spawnarray_populate(1);
}

void do_spawnarray (void) {
	spawnarray_populate(0);
}


