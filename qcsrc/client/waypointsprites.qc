float waypointsprite_initialized;
float waypointsprite_fadedistance;
float waypointsprite_normdistance;
float waypointsprite_minscale;
float waypointsprite_minalpha;
float waypointsprite_distancealphaexponent;
float waypointsprite_timealphaexponent;
float waypointsprite_scale;
float waypointsprite_fontsize;
float waypointsprite_edgefadealpha;
float waypointsprite_edgefadescale;
float waypointsprite_edgefadedistance;
float waypointsprite_edgeoffset_bottom;
float waypointsprite_edgeoffset_left;
float waypointsprite_edgeoffset_right;
float waypointsprite_edgeoffset_top;
float waypointsprite_crosshairfadealpha;
float waypointsprite_crosshairfadescale;
float waypointsprite_crosshairfadedistance;
float waypointsprite_distancefadealpha;
float waypointsprite_distancefadescale;
float waypointsprite_distancefadedistance;
float waypointsprite_alpha;

.float helpme;
.float rule;
.string netname; // primary picture
.string netname2; // secondary picture
.string netname3; // tertiary picture
.float team; // team that gets netname2
.float lifetime;
.float fadetime;
.float maxdistance;
.float hideflags;
.float spawntime;
.float health;
.float build_started;
.float build_starthealth;
.float build_finished;

float SPRITE_HEALTHBAR_WIDTH = 144;
float SPRITE_HEALTHBAR_HEIGHT = 9;
float SPRITE_HEALTHBAR_MARGIN = 6;
float SPRITE_HEALTHBAR_BORDER = 2;
float SPRITE_HEALTHBAR_BORDERALPHA = 1;
float SPRITE_HEALTHBAR_HEALTHALPHA = 0.5;
float SPRITE_ARROW_SCALE = 1.0;
float SPRITE_HELPME_BLINK = 2;

void drawrotpic(vector org, float rot, string pic, vector sz, vector hotspot, vector rgb, float a, float f)
{
	vector v1, v2, v3, v4;

	hotspot = -1 * hotspot;

	// hotspot-relative coordinates of the corners
	v1 = hotspot;
	v2 = hotspot + '1 0 0' * sz_x;
	v3 = hotspot + '1 0 0' * sz_x + '0 1 0' * sz_y;
	v4 = hotspot                  + '0 1 0' * sz_y;

	// rotate them, and make them absolute
	rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
	v1 = rotate(v1, rot) + org;
	v2 = rotate(v2, rot) + org;
	v3 = rotate(v3, rot) + org;
	v4 = rotate(v4, rot) + org;

	// draw them
	R_BeginPolygon(pic, f);
	R_PolygonVertex(v1, '0 0 0', rgb, a);
	R_PolygonVertex(v2, '1 0 0', rgb, a);
	R_PolygonVertex(v3, '1 1 0', rgb, a);
	R_PolygonVertex(v4, '0 1 0', rgb, a);
	R_EndPolygon();
}

void drawquad(vector o, vector ri, vector up, string pic, vector rgb, float a, float f)
{
	R_BeginPolygon(pic, f);
	R_PolygonVertex(o, '0 0 0', rgb, a);
	R_PolygonVertex(o + ri, '1 0 0', rgb, a);
	R_PolygonVertex(o + up + ri, '1 1 0', rgb, a);
	R_PolygonVertex(o + up, '0 1 0', rgb, a);
	R_EndPolygon();
}

void drawhealthbar(vector org, float rot, float h, vector sz, vector hotspot, float width, float height, float margin, float border, float align, vector rgb, float a, vector hrgb, float ha, float f)
{
	vector o, ri, up;
	float owidth; // outer width

	hotspot = -1 * hotspot;

	// hotspot-relative coordinates of the healthbar corners
	o = hotspot;
	ri = '1 0 0';
	up = '0 1 0';
	
	rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
	o = rotate(o, rot) + org;
	ri = rotate(ri, rot);
	up = rotate(up, rot);

	owidth = width + 2 * border;
	o = o - up * (margin + border + height) + ri * (sz_x - owidth) * 0.5;

	drawquad(o - up * border,                               ri * owidth,    up * border, "", rgb,  a,  f);
	drawquad(o + up * height,                               ri * owidth,    up * border, "", rgb,  a,  f);
	drawquad(o,                                             ri * border,    up * height, "", rgb,  a,  f);
	drawquad(o + ri * (owidth - border),                    ri * border,    up * height, "", rgb,  a,  f);
	drawquad(o + ri * (border + align * ((1 - h) * width)), ri * width * h, up * height, "", hrgb, ha, f);
}

// returns location of sprite text
vector drawspritearrow(vector o, float ang, vector rgb, float a, float t)
{
	float SQRT2 = 1.414;
	float BORDER; BORDER = 1.5 * t;
	float TSIZE; TSIZE = 8 * t;
	float RLENGTH; RLENGTH = 8 * t;
	float RWIDTH; RWIDTH = 4 * t;
	float MLENGTH; MLENGTH = 4 * t;

	R_BeginPolygon("", DRAWFLAG_NORMAL);
	R_PolygonVertex(o + rotate(eX * -(TSIZE + BORDER * (1 + SQRT2)) + eY * (TSIZE + BORDER), ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(eX *  (TSIZE + BORDER * (1 + SQRT2)) + eY * (TSIZE + BORDER), ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(eY * -(        BORDER *      SQRT2),                          ang), '0 0 0', '0 0 0', a);
	R_EndPolygon();
	R_BeginPolygon("", DRAWFLAG_NORMAL);
	R_PolygonVertex(o + rotate(eX * -(RWIDTH + BORDER) + eY * (TSIZE           + BORDER), ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(eX * -(RWIDTH + BORDER) + eY * (TSIZE + RLENGTH + BORDER), ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(eX *  (RWIDTH + BORDER) + eY * (TSIZE + RLENGTH + BORDER), ang), '0 0 0', '0 0 0', a);
	R_PolygonVertex(o + rotate(eX *  (RWIDTH + BORDER) + eY * (TSIZE           + BORDER), ang), '0 0 0', '0 0 0', a);
	R_EndPolygon();

	R_BeginPolygon("", DRAWFLAG_ADDITIVE);
	R_PolygonVertex(o + rotate(eX * -TSIZE + eY * TSIZE, ang), '0 0 0', rgb, a);
	R_PolygonVertex(o + rotate(eX *  TSIZE + eY * TSIZE, ang), '0 0 0', rgb, a);
	R_PolygonVertex(o + rotate('0 0 0',                  ang), '0 0 0', rgb, a);
	R_EndPolygon();
	R_BeginPolygon("", DRAWFLAG_ADDITIVE);
	R_PolygonVertex(o + rotate(eX * -RWIDTH + eY *  TSIZE,            ang), '0 0 0', rgb, a);
	R_PolygonVertex(o + rotate(eX * -RWIDTH + eY * (TSIZE + RLENGTH), ang), '0 0 0', rgb, a);
	R_PolygonVertex(o + rotate(eX *  RWIDTH + eY * (TSIZE + RLENGTH), ang), '0 0 0', rgb, a);
	R_PolygonVertex(o + rotate(eX *  RWIDTH + eY *  TSIZE,            ang), '0 0 0', rgb, a);
	R_EndPolygon();

	return
		o + rotate(eY * (TSIZE + RLENGTH + MLENGTH), ang);
}

// returns location of sprite healthbar
vector drawspritetext(vector o, float ang, float minwidth, vector rgb, float a, vector fontsize, string s)
{
	float algnx, algny;
	float sw, w, h;
	float aspect, sa, ca;

	sw = stringwidth(s, FALSE, fontsize);
	if(sw > minwidth)
		w = sw;
	else
		w = minwidth;
	h = fontsize_y;

	// how do corners work?
	aspect = vid_conwidth / vid_conheight;
	sa = sin(ang);
	ca = cos(ang) * aspect;
	if(fabs(sa) > fabs(ca))
	{
		algnx = (sa < 0);
		algny = 0.5 - 0.5 * ca / fabs(sa);
	}
	else
	{
		algnx = 0.5 - 0.5 * sa / fabs(ca);
		algny = (ca < 0);
	}

	// align
	o_x -= w * algnx;
	o_y -= h * algny;

	// we want to be onscreen
	if(o_x < 0)
		o_x = 0;
	if(o_y < 0)
		o_y = 0;
	if(o_x > vid_conwidth - w)
		o_x = vid_conwidth - w;
	if(o_y > vid_conheight - h)
		o_x = vid_conheight - h;

	o_x += 0.5 * (w - sw);

	drawstring(o, s, fontsize, rgb, a, DRAWFLAG_NORMAL);

	o_x += 0.5 * sw;
	o_y += 0.5 * h;

	return o;
}

float spritelookupblinkvalue(string s)
{
	switch(s)
	{
		case "ons-cp-atck-neut": return 2;
		case "ons-cp-atck-red":  return 2;
		case "ons-cp-atck-blue": return 2;
		case "ons-cp-dfnd-red":  return 0.5;
		case "ons-cp-dfnd-blue": return 0.5;
		case "item-invis":       return 2;
		case "item-extralife":   return 2;
		case "item-speed":       return 2;
		case "item-strength":    return 2;
		case "item-shield":      return 2;
		case "item-fuelregen":   return 2;
		case "item-jetpack":     return 2;
		case "tagged-target":    return 2;
		default:                 return 1;
	}
}
vector spritelookupcolor(string s, vector def)
{
	switch(s)
	{
		case "keycarrier-friend": return '0 1 0';
		case "wpn-laser":         return '1 0.5 0.5';
		case "wpn-shotgun":       return '0.5 0.25 0';
		case "wpn-uzi":           return '1 1 0';
		case "wpn-carbine":       return '1 1 0.25';
		case "wpn-gl":            return '1 0 0';
		case "wpn-mortar":        return '1 0 0';
		case "wpn-electro":       return '0 0.5 1';
		case "wpn-crylink":       return '1 0.5 1';
		case "wpn-crypistol":     return '1 0.5 1';
		case "wpn-crylancer":     return '1 0.5 1';
		case "wpn-sunbeam":       return '1 1 0.5';
		case "wpn-starlase":      return '1 1 0.5';
		case "wpn-starblast":     return '1 1 0.5';
		case "wpn-sunburst":      return '1 1 0.5';
		case "wpn-sunbolt":       return '1 1 0.5';
		case "wpn-nex":           return '0.5 1 1';
		case "wpn-hagar":         return '1 1 0.5';
		case "wpn-hagar2":        return '1 1 0.5';
		case "wpn-rl":            return '1 1 0';
		case "wpn-devastator":    return '1 1 0';
		case "wpn-flamethrower":  return '1 0.5 0';
		case "wpn-rpg7":          return '1 1 0';
		case "wpn-ra4":           return '1 0 0';
		case "wpn-seeker":        return '1 0.3 0';
		case "wpn-porto":         return '0.5 0.5 0.5';
		case "wpn-minstanex":     return '0.5 1 1';
		case "wpn-hookgun":       return '0 0.5 0';
		case "wpn-fireball":      return '1 0.5 0';
		case "wpn-hlac":          return '0 1 0';
		case "wpn-campingrifle":  return '0.5 1 0';
		case "wpn-sniperrifle":   return '0.5 1 0';
		case "wpn-lrr":   return '0.5 1 0';
		case "wpn-m82rifle":   return '0.65 0.57 0.43';
		case "wpn-lightninggun":       return '0 0.75 1';
		case "wpn-hmg":		  return '1 0.8 0';
		case "wpn-lewismg":		  return '1 1 0.5';
		case "wpn-mg":		  return '0.8 1 0';
		case "wpn-ak47":		  return '0.8 1 0';
		case "wpn-rpd":		  return '1 0.42 0.45';
		case "wpn-pkm":		  return '1 0.9 0.5';
		case "wpn-m249para":		  return '0.35 0.35 0.35';
		case "wpn-czskorpion":		  return '0.8 1 0';
		case "wpn-svskorpion":		  return '0.8 1 0';
		case "wpn-svd":		  	  return '0.8 1 0';
		case "wpn-bar1918":		  return '0.5 0.25 0.1';
		case "wpn-chauchat":		  return '0.6 0.8 0';
		case "wpn-shosho":		  return '0.5 0.5 0.5';
		case "wpn-amr18":		  return '0.1 0.1 0.1';
		case "wpn-tec9":		  return '0.1 0.1 0.1';
		case "wpn-poundersmg":	  	  return '1 0.35 0';
		case "wpn-hellriegelsmg":	  return '0.1 0.1 0.1';
		case "wpn-mg0815":	  return '0.1 0.1 0.1';
		case "wpn-sks45":		  return '0.85 1 0';
		case "wpn-aks74u":		  return '0.75 1 0';
		case "wpn-m16mini":		  return '0.75 1 0';
		case "wpn-spectre":		  return '0.74 0.74 0.74';
		case "wpn-m16vn":		  return '0.9 0.9 0';
		case "wpn-m16a2":		  return '0.9 0.9 0';
		case "wpn-fnscar":		  return '0.75 0.662 0.51';
		case "wpn-g36c":		  return '0.9 0.9 0';
		case "wpn-l85a2":		  return '0.85 0.9 0.75';
		case "wpn-famas":		  return '0.85 0.9 0.75';
		case "wpn-styeraug":		  return '0.9 0.85 0.75';
		case "wpn-styertmp":		  return '0.9 0.85 0.75';
		case "wpn-p90":		  return '0.75 0.75 0.75';
		case "wpn-minelayer":     return '0.75 1 0';
		case "wpn-shotgunautomat":       return '1 0.30 0';
		case "wpn-pistol":           return '1 1 0.15';
		case "wpn-bigpistol":           return '1 1 0.25';
		case "wpn-longpistol":           return '0.1 0.1 0.1';
		case "wpn-browninghp":           return '1 1 0.25';
		case "wpn-largepistol":           return '1 1 0.5';
		case "wpn-lightpistol":        return '1 1 0';
		case "wpn-fivesevenpistol":        return '0.75 0.75 0.75';
		case "wpn-mauserpistol":        return '1 1 0';
		case "wpn-m9pistol":        return '1 1 0';
		case "wpn-m93rpistol":        return '1 1 0';
		case "wpn-tt33pistol":        return '1 1 0.25';
		case "wpn-lightauto":        return '0.9 1 0';
		case "wpn-machinepistol":        return '0.9 1 0';
		case "wpn-microuzi":        return '1 0.9 0';
		case "wpn-miniuzi":        return '1 0.9 0';
		case "wpn-revolver":           return '1 1 0.065';
		case "wpn-navy1851revolver":           return '0.95 0.95 0.9';
		case "wpn-r1856revolver":           return '0.95 0.95 0.9';
		case "wpn-colt44revolver":           return '0.95 0.95 0.95';
		case "wpn-schofieldrevolver":           return '0.5 0.3 0.1';
		case "wpn-henry1860rifle":           return '0.75 0.75 0.30';
		case "wpn-winchester1873rifle":           return '0.75 0.75 0.75';
		case "wpn-henry1860maresleg":           return '0.75 0.75 0.30';
		case "wpn-coltlightning":           return '0.65 0.75 0.75';
		case "wpn-winchester1897":           return '0.75 0.75 0.75';
		case "wpn-m1897trenchgun":           return '0.45 0.45 0.45';
		case "wpn-ithacastakeout":           return '0.43 0.43 0.43';
		case "wpn-streetsweeper":           return '0.39 0.39 0.39';
		case "wpn-sharpsrifle":           return '0.62 0.62 0.40';
		case "wpn-magnum":           return '0.75 0.75 0.065';
		case "wpn-nagant1895":           return '0.40 0.00 0.00';
		case "wpn-webley":           return '0.2 0.2 0.2';
		case "wpn-webleylong":           return '0.65 0.64 0.42';
		case "wpn-ffmagnum":           return '0.75 0.75 0.055';
		case "wpn-pepperboxrevolver":           return '0.7 0.5 0.6';
		case "wpn-flintlockpistol":           return '0.4 0.4 0.4';
		case "wpn-musket":           return '0.4 0.4 0.4';
		case "wpn-tanegashima":           return '0.32 0.32 0.32';
		case "wpn-m1921":           return '1 1 0';
		case "wpn-m1928":           return '1 1 0';
		case "wpn-m1929":           return '1 1 0';
		case "wpn-pdw":           return '0 1 0.4';
		case "wpn-pumpshotgun":       return '0.5 0.25 0';
		case "wpn-sportshotgun":       return '0.5 0.25 0';
		case "wpn-eightgaugeshotgun":       return '0.5 0.25 0';
		case "wpn-tengaugedouble":       return '0.35 0.35 0.35';
		case "wpn-tengaugesawedoff":       return '0.35 0.35 0.35';
		case "wpn-eightgaugesawedoff":       return '0.5 0.25 0';
		case "wpn-spas12":		  return '0.1 0.1 0.1';
		case "wpn-warhammerspiked":       return '0.1 0.1 0.1';
		case "wpn-kriegshammer":       return '0.8 0.8 0.8';
		case "wpn-clawhammer":       return '0.9 0.45 0.1';
		case "wpn-tetsubo":       return '0.08 0.08 0.08';
		case "wpn-bronzecudgel":       return '0.3 0.3 0.08';
		case "wpn-flangedmace":       return '0.18 0.18 0.18';
		case "wpn-cudgel":       return '0.32 0.16 0.08';
		case "wpn-spikedcudgel":       return '0.30 0.14 0.065';
		case "wpn-bat":       return '0.32 0.30 0.08';
		case "wpn-quarterstaff":       return '0.32 0.16 0.08';
		case "wpn-infantrystaff":       return '0.35 0.35 0.35';
		case "wpn-spikedclub":       return '0.3 0.14 0.08';
		case "wpn-kiduchi":       return '0.4 0.38 0.08';
		case "wpn-staffflame":       return '1.0 0.0 0.0';
		case "wpn-staffmagi":       return '1.0 0.0 1.0';
		case "wpn-elvenstaff":       return '0.16 0.32 0.16';
		case "wpn-elvenhammer":       return '0.1 0.2 0.1';
		case "wpn-warmallet":       return '0.3 0.15 0.08';
		case "wpn-greyironmallet":       return '0.35 0.35 0.35';
		case "wpn-crowbar":       return '0.50 0.08 0.08';
		case "wpn-ironcrow":       return '0.08 0.08 0.08';
		case "wpn-morgenstern":       return '0.05 0.05 0.05';
		case "wpn-spikedflail":       return '0.05 0.05 0.05';
		case "wpn-milflail":       return '0.5 0.5 0.5';
		case "wpn-shiningstar":       return '0.8 0.8 0.8';
		case "wpn-spikedmace":       return '0.8 0.8 0.8';
		case "wpn-shootingstar":       return '0.75 0.75 0.75';
		case "wpn-shortsword":       return '0.4 0.4 0.4';
		case "wpn-longsword":       return '0.35 0.35 0.35';
		case "wpn-armingsword":       return '0.4 0.4 0.4';
		case "wpn-crusadersword":       return '0.5 0 0';
		case "wpn-fightersword":       return '0.35 0.35 0.35';
		case "wpn-scimitar":       return '0.4 0.4 0.26';
		case "wpn-falchion":       return '0.38 0.38 0.38';
		case "wpn-dadao":       return '0.8 0.0 0.0';
		case "wpn-pudao":       return '0.32 0.32 0.32';
		case "wpn-bastardsword":       return '0.3 0.3 0.3';
		case "wpn-claymore":       return '0.5 0.5 0.5';
		case "wpn-flamberge":       return '0.8 0.4 0.0';
		case "wpn-defendersword":       return '0.32 0.32 0.32';
		case "wpn-ironknife":       return '0.18 0.18 0.18';
		case "wpn-knife":       return '0.5 0.5 0.5';
		case "wpn-bowieknife":       return '0.8 0.8 0.5';
		case "wpn-arkansastoothpick":       return '0.7 0.7 0.4';
		case "wpn-elvensabre":       return '0.3 0.43 0.3';
		case "wpn-katana":       return '0.3 0.3 0.3';
		case "wpn-shirasaya":       return '0.746 0.621 0.402';
		case "wpn-zatoichi":       return '0.15 0.0 0.0';
		case "wpn-odachi":       return '0.28 0.28 0.28';
		case "wpn-nagamaki":       return '0.25 0.25 0.25';
		case "wpn-elvenglaive":       return '0.25 0.37 0.25';
		case "wpn-rapier":       return '0.4 0.4 0.4';
		case "wpn-dagger":       return '0.4 0.4 0.4';
		case "wpn-sai":       return '0.12 0.12 0.12';
		case "wpn-lightsabre":       return '0.45 0.0 0.0';
		case "wpn-lightsabreii":       return '1 0.0 0.0';
		case "wpn-lightsabreiv":       return '0 1 0.0';
		case "wpn-lightsabrexi":       return '0 0.1 0.8';
		case "wpn-spear":       return '0.5 0.4 0.2';
		case "wpn-yari":       return '0.6 0.5 0.4';
		case "wpn-broadaxe":       return '0.01 0.01 0.01';
		case "wpn-waraxe":       return '0.31 0.31 0.31';
		case "wpn-skirmishersaxe":       return '0.7 0.7 0.7';
		case "wpn-battleaxe":       return '0.41 0.0 0.05';
		case "wpn-templaraxe":       return '0.1 0.1 0.1';
		case "wpn-woodaxe":      return '0.30 0.20 0.09';
		case "wpn-beardedaxe":      return '0.28 0.18 0.07';
		case "wpn-axe":      return '0.29 0.19 0.08';
		case "wpn-pickaxe":      return '0.1 0.1 0.1';
		case "wpn-doublebitaxe":      return '0.31 0.20 0.10';
		case "wpn-chainsaw":       return '0.8 0.4 0.1';
		case "wpn-powersaw":       return '0.7 0.3 0.1';
		case "wpn-poleaxe":       return '0.25 0.25 0.25';
		case "wpn-bardiche":       return '0.52 0.52 0.52';
		case "wpn-infantryaxe":       return '0.35 0.35 0.35';
		case "wpn-elvenaxe":       return '0.35 0.48 0.35';
		case "wpn-stoneaxe":       return '0.4 0.4 0.4';
		case "wpn-crossbowdtwr":       return '0.2 0.2 0.2';
		case "wpn-longbow":       return '0.5 0.3 0.2';
		case "wpn-yumibow":       return '0.6 0.3 0.2';
		case "wpn-lightcrossbow":       return '0.47 0.3 0.15';
		case "wpn-compositebow":       return '0.45 0.25 0.15';
		case "wpn-crudebow":       return '0.5 0.3 0.15';
		case "wpn-caltrop":       return '0.1 0.1 0.1';
		case "wpn-shackles":       return '0.45 0.45 0.3';
		case "wpn-handcuffs":       return '0.5 0.5 0.5';
		case "wpn-multitool":       return '0.3 0.3 0.3';
		case "wpn-utilitool":       return '0.3 0.6 0.6';
		case "wpn-torch":       return '0.3 0.1 0.1';
		case "wpn-flashlight":       return '0.5 0.6 1';
		case "wpn-explosivevest":            return '1 0 0.25';
		case "wpn-nukelayer":       return '1 1 0.20';
		case "wpn-mac10_unsuppressed":           return '1 1 0';
		case "wpn-g3":		  return '0.8 1 0';
		case "wpn-g98":   return '0.7 1 0';
		case "wpn-mosin":   return '0.6 1 0';
		case "wpn-t17mmrifle":   return '0.2 0.2 0.2';
		case "wpn-m1903":   return '0.5 0.5 0.2';
		case "wpn-targetpistol":   return '0.6 0.5 0.1';
		default:                  return def;
	}
}
string spritelookuptext(string s)
{
	switch(s)
	{
		case "as-push": return _("Push");
		case "as-destroy": return _("Destroy");
		case "as-defend": return _("Defend");
		case "bluebase": return _("Blue base");
		case "danger": return _("DANGER");
		case "enemyflagcarrier": return _("Enemy carrier");
		case "flagcarrier": return _("Flag carrier");
		case "flagdropped": return _("Dropped flag");
		case "helpme": return _("Help me!");
		case "here": return _("Here");
		case "key-dropped": return _("Dropped key");
		case "keycarrier-blue": return _("Key carrier");
		case "keycarrier-finish": return _("Run here");
		case "keycarrier-friend": return _("Key carrier");
		case "keycarrier-pink": return _("Key carrier");
		case "keycarrier-red": return _("Key carrier");
		case "keycarrier-yellow": return _("Key carrier");
		case "redbase": return _("Red base");
		case "waypoint": return _("Waypoint");
		case "ons-gen-red": return _("Generator");
		case "ons-gen-blue": return _("Generator");
		case "ons-gen-shielded": return _("Generator");
		case "ons-cp-neut": return _("Control point");
		case "ons-cp-red": return _("Control point");
		case "ons-cp-blue": return _("Control point");
		case "ons-cp-atck-neut": return _("Control point");
		case "ons-cp-atck-red": return _("Control point");
		case "ons-cp-atck-blue": return _("Control point");
		case "ons-cp-dfnd-red": return _("Control point");
		case "ons-cp-dfnd-blue": return _("Control point");
		case "race-checkpoint": return _("Checkpoint");
		case "race-finish": return _("Finish");
		case "race-start": return _("Start");
		case "race-start-finish": return (race_checkpointtime || race_mycheckpointtime) ? _("Finish") : _("Start");
		case "nb-ball": return _("Ball");
		case "ka-ball": return _("Ball");
		case "ka-ballcarrier": return _("Ball carrier");
		case "wpn-laser": return _("Laser");
		case "wpn-shotgun": return _("Shotgun");
		case "wpn-uzi": return _("Machine Gun");
		case "wpn-carbine": return _("Carbine");
		case "wpn-gl": return _("Mortar");
		case "wpn-mortar": return _("MortarCannon");
		case "wpn-electro": return _("Electro");
		case "wpn-crylink": return _("Crylink");
		case "wpn-crypistol": return _("Crypistol");
		case "wpn-crylancer": return _("Crylancer");
		case "wpn-sunbeam": return _("Sunbeam");
		case "wpn-starlase": return _("Starlase");
		case "wpn-starblast": return _("Starblast");
		case "wpn-sunburst": return _("Sunburst");
		case "wpn-sunbolt": return _("Sunbolt");
		case "wpn-nex": return _("Nex");
		case "wpn-hagar": return _("Hagar");
		case "wpn-hagar2": return _("Hagar-2");
		case "wpn-rl": return _("Rocket Launcher");
		case "wpn-devastator": return _("Devastator");
		case "wpn-flamethrower": return _("FlamerThrower");
		case "wpn-rpg7": return _("RPG7");
		case "wpn-ra4": return _("RA4");
		case "wpn-porto": return _("Port-O-Launch");
		case "wpn-minstanex": return _("Minstanex");
		case "wpn-hookgun": return _("Hook");
		case "wpn-fireball": return _("Fireball");
		case "wpn-hlac": return _("HLAC");
		case "wpn-campingrifle": return _("Rifle");
		case "wpn-lrr": return _("Long Range Rifle");
		case "wpn-m82rifle": return _("M82 Rifle");
		case "wpn-hmg": return _("Heavy Machine Gun");
		case "wpn-lewismg": return _("Lewis Gun");
		case "wpn-mg": return _("Assault Rifle");
		case "wpn-g3": return _("Assault Rifle");
		case "wpn-mac10_unsuppressed": return _("Machine Gun");
		case "wpn-minelayer": return _("Mine Layer");
		case "wpn-shotgunautomat": return _("ShotgunAutomat");
		case "wpn-pumpshotgun": return _("Pump Shotgun");
		case "wpn-sportshotgun": return _("Sport Shotgun");
		case "wpn-eightgaugeshotgun": return _("8ga Shotgun");
		case "wpn-tengaugedouble": return _("10ga Double");
		case "wpn-tengaugesawedoff": return _("10ga Sawed-Off");
		case "wpn-eightgaugesawedoff": return _("8ga Sawed-Off");
		case "wpn-spas12": return _("SPAS-12");
		case "wpn-explosivevest": return _("Explosives");
		case "wpn-nukelayer": return _("Nuke Layer");
		case "wpn-mac10_unsuppressed": return _("Machine Gun");
		case "wpn-lightninggun": return _("Lightning Gun");
		case "wpn-g98": return _("G98 Rifle");
		case "wpn-mosin": return _("Mosin Rifle");
		case "wpn-t17mm": return _("T17mm Rifle");
		case "wpn-m1903": return _("M1903 Rifle");
		case "wpn-targetpistol": return _("Target Pistol");
		case "wpn-pistol": return _("Pistol");
		case "wpn-bigpistol": return _(".45 Pistol");
		case "wpn-longpistol": return _(".45 Longslide");
		case "wpn-largepistol": return _(".50 Pistol");
		case "wpn-lightpistol": return _("9mm Pistol");
		case "wpn-fivesevenpistol": return _("5.7mm Pistol");
		case "wpn-mauserpistol": return _("Mauser Pistol");
		case "wpn-m9pistol": return _("M9 Pistol");
		case "wpn-m93rpistol": return _("93R Pistol");
		case "wpn-browninghp": return _("9mm HiPower");
		case "wpn-tt33pistol": return _("TT33 Pistol");
		case "wpn-lightauto": return _("9mm AutoPistol");
		case "wpn-machinepistol": return _("MachinePistol");
		case "wpn-microuzi": return _("MicroUzi");
		case "wpn-miniuzi": return _("Uzi");
		case "wpn-ak47": return _("AK-47");
		case "wpn-rpd": return _("RPD");
		case "wpn-pkm": return _("PKM");
		case "wpn-m249para": return _("M249-Para");
		case "wpn-czskorpion": return _("CZ Skorpion");
		case "wpn-svskorpion": return _("SV Skorpion");
		case "wpn-svd": return _("SVD");
		case "wpn-bar1918": return _("BAR-1918");
		case "wpn-chauchat": return _("Chauchat");
		case "wpn-shosho": return _("Sho-Sho");
		case "wpn-amr18": return _("AMR-18");
		case "wpn-tec9": return _("Tec-9");
		case "wpn-poundersmg": return _("Pounder-SMG");
		case "wpn-hellriegelsmg": return _("Hellriegel SMG");
		case "wpn-mg0815": return _("MG 08/15");
		case "wpn-sks45": return _("SKS-45");
		case "wpn-aks74u": return _("AKS-74u");
		case "wpn-m16mini": return _("M16-Mini");
		case "wpn-spectre": return _("Spectre");
		case "wpn-m16vn": return _("M16-Vn");
		case "wpn-m16a2": return _("M16A2");
		case "wpn-fnscar": return _("FN SCAR-H");
		case "wpn-g36c": return _("G36C");
		case "wpn-l85a2": return _("L85A2");
		case "wpn-famas": return _("FAMAS");
		case "wpn-styeraug": return _("Styer Aug");
		case "wpn-styertmp": return _("Styer TMP");
		case "wpn-p90": return _("P90");
		case "wpn-revolver": return _("Revolver");
		case "wpn-navy1851revolver": return _("Navy 1851");
		case "wpn-r1856revolver": return _("Remington 1856");
		case "wpn-colt44revolver": return _("Colt 44");
		case "wpn-schofieldrevolver": return _("Schofield");
		case "wpn-henry1860rifle": return _("Henry Rifle");
		case "wpn-winchester1873rifle": return _("Winchester Rifle");
		case "wpn-henry1860maresleg": return _("Mare's Leg");
		case "wpn-coltlightning": return _("Colt Lightning");
		case "wpn-winchester1897": return _("Winchester 1897");
		case "wpn-m1897trenchgun": return _("M1897 Trenchgun");
		case "wpn-ithacastakeout": return _("Ithaca Stakeout");
		case "wpn-streetsweeper": return _("Street Sweeper");
		case "wpn-sharpsrifle": return _("Sharps Rifle");
		case "wpn-magnum": return _("357 Magnum");
		case "wpn-nagant1895": return _("Nagant M1895");
		case "wpn-webley": return _("Webley");
		case "wpn-webleylong": return _("Webley Dragoon");
		case "wpn-ffmagnum": return _("44 Magnum");
		case "wpn-pepperboxrevolver": return _("Pepperbox");
		case "wpn-flintlockpistol": return _("Flintlock");
		case "wpn-musket": return _("Musket");
		case "wpn-tanegashima": return _("Tanegashima");
		case "wpn-m1921": return _(".45 SMG 1921");
		case "wpn-m1928": return _(".45 SMG 1928");
		case "wpn-m1929": return _(".45 SMG 1929M");
		case "wpn-pdw": return _("PDW Sub-Machine Gun");
		case "wpn-sniperrifle": return _("Rifle");
		case "wpn-seeker": return _("Seeker");
		case "wpn-crossbowdtwr": return _("Crossbow");
		case "wpn-longbow": return _("Longbow");
		case "wpn-yumibow": return _("Yumi");
		case "wpn-lightcrossbow": return _("Light Crossbow");
		case "wpn-compositebow": return _("Composite Bow");
		case "wpn-crudebow": return _("Crude Bow");
		case "wpn-warhammerspiked": return _("War Hammer");
		case "wpn-kriegshammer": return _("Kriegshammer");
		case "wpn-clawhammer": return _("Claw Hammer");
		case "wpn-tetsubo": return _("Tetsubo");
		case "wpn-bronzecudgel": return _("Bronze Cudgel");
		case "wpn-flangedmace": return _("Flanged Mace");
		case "wpn-cudgel": return _("Cudgel");
		case "wpn-spikedcudgel": return _("Spiked Cudgel");
		case "wpn-bat": return _("Bat");
		case "wpn-quarterstaff": return _("Quarterstaff");
		case "wpn-infantrystaff": return _("Infantry Staff");
		case "wpn-spikedclub": return _("Spiked Club");
		case "wpn-kiduchi": return _("Kiduchi");
		case "wpn-staffflame": return _("Staff of Flame");
		case "wpn-staffmagi": return _("Magicians Staff");
		case "wpn-elvenstaff": return _("Elven Staff");
		case "wpn-elvenhammer": return _("Elven Hammer");
		case "wpn-warmallet": return _("War Mallet");
		case "wpn-greyironmallet": return _("Grey Iron Mallet");
		case "wpn-crowbar": return _("Crowbar");
		case "wpn-ironcrow": return _("IronCrow");
		case "wpn-morgenstern": return _("Morgenstern");
		case "wpn-spikedflail": return _("Spiked Flail");
		case "wpn-milflail": return _("Military Flail");
		case "wpn-shiningstar": return _("Shiningstar");
		case "wpn-spikedmace": return _("Spiked Mace");
		case "wpn-shootingstar": return _("Shooting-Star");
		case "wpn-shortsword": return _("Short Sword");
		case "wpn-longsword": return _("Long Sword");
		case "wpn-armingsword": return _("Arming Sword");
		case "wpn-crusadersword": return _("Crusader Sword");
		case "wpn-fightersword": return _("Fighter Sword");
		case "wpn-scimitar": return _("Scimitar");
		case "wpn-falchion": return _("Falchion");
		case "wpn-dadao": return _("Dadao");
		case "wpn-pudao": return _("Pudao");
		case "wpn-bastardsword": return _("Bastard Sword");
		case "wpn-claymore": return _("Claymore");
		case "wpn-flamberge": return _("Flamberge");
		case "wpn-defendersword": return _("Defender Sword");
		case "wpn-ironknife": return _("Iron Knife");
		case "wpn-knife": return _("Knife");
		case "wpn-bowieknife": return _("Bowie Knife");
		case "wpn-arkansastoothpick": return _("Arkansas Toothpick");
		case "wpn-elvensabre": return _("Elven Sabre");
		case "wpn-katana": return _("Katana");
		case "wpn-shirasaya": return _("Shirasaya");
		case "wpn-zatoichi": return _("Zatoichi");
		case "wpn-odachi": return _("Odachi");
		case "wpn-nagamaki": return _("Nagamaki");
		case "wpn-elvenglaive": return _("Elven Glaive");
		case "wpn-rapier": return _("Rapier");
		case "wpn-dagger": return _("Dagger");
		case "wpn-sai": return _("Sai");
		case "wpn-lightsabre": return _("Lightsabre");
		case "wpn-lightsabreii": return _("LightsabreII");
		case "wpn-lightsabreiv": return _("LightsabreIV");
		case "wpn-lightsabrexi": return _("LightsabreXI");
		case "wpn-spear": return _("Spear");
		case "wpn-yari": return _("Yari");
		case "wpn-broadaxe": return _("Broad Axe");
		case "wpn-waraxe": return _("War Axe");
		case "wpn-skirmishersaxe": return _("Skirmisher's Axe");
		case "wpn-battleaxe": return _("Battle Axe");
		case "wpn-templaraxe": return _("Templar Axe");
		case "wpn-woodaxe": return _("Woodsman's Axe");
		case "wpn-beardedaxe": return _("Bearded Axe");
		case "wpn-axe": return _("Axe");
		case "wpn-pickaxe": return _("Pickaxe");
		case "wpn-doublebitaxe": return _("DoubleBit Axe");
		case "wpn-infantryaxe": return _("Infantry Axe");
		case "wpn-elvenaxe": return _("Elven Axe");
		case "wpn-chainsaw": return _("Chainsaw");
		case "wpn-powersaw": return _("Power Saw");
		case "wpn-poleaxe": return _("Pole Axe");
		case "wpn-bardiche": return _("Bardiche");
		case "wpn-stoneaxe": return _("Stone Axe");
		case "wpn-caltrop": return _("Caltrops");
		case "wpn-shackles": return _("Shackles");
		case "wpn-handcuffs": return _("Handcuffs");
		case "wpn-multitool": return _("Multi Tool");
		case "wpn-utilitool": return _("Utili Tool");
		case "wpn-torch": return _("Torch");
		case "wpn-flashlight": return _("Flashlight");
		case "dom-neut": return _("Control point");
		case "dom-red": return _("Control point");
		case "dom-blue": return _("Control point");
		case "dom-yellow": return _("Control point");
		case "dom-pink": return _("Control point");
		case "item-invis": return _("Invisibility");
		case "item-extralife": return _("Extra life");
		case "item-speed": return _("Speed");
		case "item-strength": return _("Strength");
		case "item-shield": return _("Shield");
		case "item-fuelregen": return _("Fuel regen");
		case "item-jetpack": return _("Jet Pack");
		case "freezetag_frozen": return _("Frozen!");
		case "tagged-target": return _("Tagged");
		case "vehicle": return _("Vehicle");
		default: return s;
	}
}

vector fixrgbexcess_move(vector rgb, vector src, vector dst)
{
	vector yvec = '0.299 0.587 0.114';
	return rgb + dst * ((src * yvec) / (dst * yvec)) * ((rgb - '1 1 1') * src);
}
vector fixrgbexcess(vector rgb)
{
	if(rgb_x > 1)
	{
		rgb = fixrgbexcess_move(rgb, '1 0 0', '0 1 1');
		if(rgb_y > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 1 0', '0 0 1');
			if(rgb_z > 1)
				rgb_z = 1;
		}
		else if(rgb_z > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 0 1', '0 1 0');
			if(rgb_y > 1)
				rgb_y = 1;
		}
	}
	else if(rgb_y > 1)
	{
		rgb = fixrgbexcess_move(rgb, '0 1 0', '1 0 1');
		if(rgb_x > 1)
		{
			rgb = fixrgbexcess_move(rgb, '1 0 0', '0 0 1');
			if(rgb_z > 1)
				rgb_z = 1;
		}
		else if(rgb_z > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 0 1', '1 0 0');
			if(rgb_x > 1)
				rgb_x = 1;
		}
	}
	else if(rgb_z > 1)
	{
		rgb = fixrgbexcess_move(rgb, '0 0 1', '1 1 0');
		if(rgb_x > 1)
		{
			rgb = fixrgbexcess_move(rgb, '1 0 0', '0 1 0');
			if(rgb_y > 1)
				rgb_y = 1;
		}
		else if(rgb_y > 1)
		{
			rgb = fixrgbexcess_move(rgb, '0 1 0', '1 0 0');
			if(rgb_x > 1)
				rgb_x = 1;
		}
	}
	return rgb;
}

float waypointsprite_count, waypointsprite_newcount;
void Draw_WaypointSprite()
{
	string spriteimage;
	float t;

	if(self.lifetime)
		self.alpha = pow(bound(0, (self.fadetime - time) / self.lifetime, 1), waypointsprite_timealphaexponent);
	else
		self.alpha = 1;

	if(self.hideflags & 2)
		return; // radar only

	if(autocvar_cl_hidewaypoints >= 2)
		return;

	if(self.hideflags & 1)
		if(autocvar_cl_hidewaypoints)
			return; // fixed waypoint

	InterpolateOrigin_Do();

	t = GetPlayerColor(player_localnum) + 1;

	spriteimage = "";

	// choose the sprite
	switch(self.rule)
	{
		case SPRITERULE_DEFAULT:
			if(self.team)
			{
				if(self.team == t)
					spriteimage = self.netname;
				else
					spriteimage = "";
			}
			else
				spriteimage = self.netname;
			break;
		case SPRITERULE_TEAMPLAY:
			if(t == COLOR_SPECTATOR + 1)
				spriteimage = self.netname3;
			else if(self.team == t)
				spriteimage = self.netname2;
			else
				spriteimage = self.netname;
			break;
		default:
			error("Invalid waypointsprite rule!");
			break;
	}

	if(spriteimage == "")
		return;

	++waypointsprite_newcount;
	
	float dist;
	dist = vlen(self.origin - view_origin);
	
	float a;
	a = self.alpha * autocvar_hud_panel_fg_alpha;

	if(self.maxdistance > waypointsprite_normdistance)
		a *= pow(bound(0, (self.maxdistance - dist) / (self.maxdistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent);
	else if(self.maxdistance > 0)
		a *= pow(bound(0, (waypointsprite_fadedistance - dist) / (waypointsprite_fadedistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent) * (1 - waypointsprite_minalpha) + waypointsprite_minalpha;

	vector rgb;
	rgb = self.teamradar_color;
	rgb = spritelookupcolor(spriteimage, rgb);
	if(rgb == '0 0 0')
	{
		self.teamradar_color = '1 0 1';
		print(sprintf("WARNING: sprite of name %s has no color, using pink so you notice it\n", spriteimage)); 
	}

	if(time - floor(time) > 0.5)
	{
		if(self.helpme && time < self.helpme)
			a *= SPRITE_HELPME_BLINK;
		else
			a *= spritelookupblinkvalue(spriteimage);
	}

	if(a > 1)
	{
		rgb *= a;
		a = 1;
	}

	if(a <= 0)
		return;

	rgb = fixrgbexcess(rgb);

	vector o;
	float ang;

	o = project_3d_to_2d(self.origin);
	if(o_z < 0 
	|| o_x < (vid_conwidth * waypointsprite_edgeoffset_left) 
	|| o_y < (vid_conheight * waypointsprite_edgeoffset_top) 
	|| o_x > (vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right))  
	|| o_y > (vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)))
	{
		// scale it to be just in view
		vector d;
		float f1, f2;

		d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;
		ang = atan2(-d_x, -d_y);
		if(o_z < 0)
			ang += M_PI;

		f1 = d_x / vid_conwidth;
		f2 = d_y / vid_conheight;

		if(max(f1, -f1) > max(f2, -f2))
		{
			if(d_z * f1 > 0)
			{
				// RIGHT edge
				d = d * ((0.5 - waypointsprite_edgeoffset_right) / f1);
			}
			else
			{
				// LEFT edge
				d = d * (-(0.5 - waypointsprite_edgeoffset_left) / f1);
			}
		}
		else
		{
			if(d_z * f2 > 0)
			{
				// BOTTOM edge
				d = d * ((0.5 - waypointsprite_edgeoffset_bottom) / f2);
			}
			else
			{
				// TOP edge
				d = d * (-(0.5 - waypointsprite_edgeoffset_top) / f2);
			}
		}

		o = d + '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
	}
	else
	{
#if 1
		ang = M_PI;
#else
		vector d;
		d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;
		ang = atan2(-d_x, -d_y);
#endif
	}
	o_z = 0;

	float edgedistance_min, crosshairdistance;
		edgedistance_min = min((o_y - (vid_conheight * waypointsprite_edgeoffset_top)), 
	(o_x - (vid_conwidth * waypointsprite_edgeoffset_left)),
	(vid_conwidth - (vid_conwidth * waypointsprite_edgeoffset_right)) - o_x, 
	(vid_conheight - (vid_conheight * waypointsprite_edgeoffset_bottom)) - o_y);

	float vidscale;
	vidscale = max(vid_conwidth / vid_width, vid_conheight / vid_height);

	crosshairdistance = sqrt( pow(o_x - vid_conwidth/2, 2) + pow(o_y - vid_conheight/2, 2) );

	t = waypointsprite_scale * vidscale;
	a *= waypointsprite_alpha;

	{
		a = a * (1 - (1 - waypointsprite_distancefadealpha) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_distancefadescale) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
	}
	if (edgedistance_min < waypointsprite_edgefadedistance) {
		a = a * (1 - (1 - waypointsprite_edgefadealpha) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_edgefadescale) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
	}
	if(crosshairdistance < waypointsprite_crosshairfadedistance) {
		a = a * (1 - (1 - waypointsprite_crosshairfadealpha) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_crosshairfadescale) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
	}

	if(self.build_finished)
	{
		if(time < self.build_finished + 0.25)
		{
			if(time < self.build_started)
				self.health = self.build_starthealth;
			else if(time < self.build_finished)
				self.health = (time - self.build_started) / (self.build_finished - self.build_started) * (1 - self.build_starthealth) + self.build_starthealth;
			else
				self.health = 1;
		}
		else
			self.health = -1;
	}

	o = drawspritearrow(o, ang, rgb, a, SPRITE_ARROW_SCALE * t);
	
	string txt;
	if(autocvar_g_waypointsprite_spam && waypointsprite_count >= autocvar_g_waypointsprite_spam)
		txt = _("Spam");
	else
		txt = spritelookuptext(spriteimage);
	if(self.helpme && time < self.helpme)
		txt = sprintf(_("%s needing help!"), txt);
	if(autocvar_g_waypointsprite_uppercase)
		txt = strtoupper(txt);

	draw_beginBoldFont();
	if(self.health >= 0)
	{
		o = drawspritetext(o, ang, (SPRITE_HEALTHBAR_WIDTH + 2 * SPRITE_HEALTHBAR_BORDER) * t, rgb, a, waypointsprite_fontsize * '1 1 0', txt);

		float align, marg;
		if(self.build_finished)
			align = 0.5;
		else
			align = 0;
		if(cos(ang) > 0)
			marg = -(SPRITE_HEALTHBAR_MARGIN + SPRITE_HEALTHBAR_HEIGHT + 2 * SPRITE_HEALTHBAR_BORDER) * t - 0.5 * waypointsprite_fontsize;
		else
			marg = SPRITE_HEALTHBAR_MARGIN * t + 0.5 * waypointsprite_fontsize;
		drawhealthbar(
				o,
				0,
				self.health,
				'0 0 0',
				'0 0 0',
				SPRITE_HEALTHBAR_WIDTH * t,
				SPRITE_HEALTHBAR_HEIGHT * t,
				marg,
				SPRITE_HEALTHBAR_BORDER * t,
				align,
				rgb,
				a * SPRITE_HEALTHBAR_BORDERALPHA,
				rgb,
				a * SPRITE_HEALTHBAR_HEALTHALPHA,
				DRAWFLAG_NORMAL
			     );
	}
	else
	{
		o = drawspritetext(o, ang, 0, rgb, a, waypointsprite_fontsize * '1 1 0', txt);
	}
	draw_endBoldFont();
}

void Ent_RemoveWaypointSprite()
{
	if(self.netname)
		strunzone(self.netname);
	if(self.netname2)
		strunzone(self.netname2);
	if(self.netname3)
		strunzone(self.netname3);
}

void Ent_WaypointSprite()
{
	float sendflags, f, t;
	sendflags = ReadByte();

	if(!self.spawntime)
		self.spawntime = time;

	self.draw2d = Draw_WaypointSprite;

	InterpolateOrigin_Undo();

	if(sendflags & 0x80)
	{
		t = ReadByte();
		if(t < 192)
		{
			self.health = t / 191.0;
			self.build_finished = 0;
		}
		else
		{
			t = (t - 192) * 256 + ReadByte();
			self.build_started = servertime;
			if(self.build_finished)
				self.build_starthealth = bound(0, self.health, 1);
			else
				self.build_starthealth = 0;
			self.build_finished = servertime + t / 32;
		}
	}
	else
	{
		self.health = -1;
		self.build_finished = 0;
	}

	if(sendflags & 64)
	{
		// unfortunately, this needs to be exact (for the 3D display)
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}

	if(sendflags & 1)
	{
		self.team = ReadByte();
		self.rule = ReadByte();
	}

	if(sendflags & 2)
	{
		if(self.netname)
			strunzone(self.netname);
		self.netname = strzone(ReadString());
	}

	if(sendflags & 4)
	{
		if(self.netname2)
			strunzone(self.netname2);
		self.netname2 = strzone(ReadString());
	}

	if(sendflags & 8)
	{
		if(self.netname3)
			strunzone(self.netname3);
		self.netname3 = strzone(ReadString());
	}

	if(sendflags & 16)
	{
		self.lifetime = ReadCoord();
		self.fadetime = ReadCoord();
		self.maxdistance = ReadShort();
		self.hideflags = ReadByte();
	}

	if(sendflags & 32)
	{
		f = ReadByte();
		self.teamradar_icon = (f & 0x7F);
		if(f & 0x80)
		{
			self.(teamradar_times[self.teamradar_time_index]) = time;
			self.teamradar_time_index = mod(self.teamradar_time_index + 1, MAX_TEAMRADAR_TIMES);
		}
		self.teamradar_color_x = ReadByte() / 255.0;
		self.teamradar_color_y = ReadByte() / 255.0;
		self.teamradar_color_z = ReadByte() / 255.0;
		self.helpme = ReadByte() * 0.1;
		if(self.helpme > 0)
			self.helpme += servertime;
	}

	InterpolateOrigin_Note();

	self.entremove = Ent_RemoveWaypointSprite;
}

void WaypointSprite_Load_Frames(string ext)
{
	float dh, n, i, o, f;
	string s, sname, sframes;
	dh = search_begin(strcat("models/sprites/*_frame*", ext), FALSE, FALSE);
	if (dh < 0)
		 return;
	float ext_len = strlen(ext);
	n = search_getsize(dh);
	for(i = 0; i < n; ++i)
	{
		s = search_getfilename(dh, i);
		s = substring(s, 15, strlen(s) - 15 - ext_len); // strip models/sprites/ and extension

		o = strstrofs(s, "_frame", 0);
		sname = strcat("/spriteframes/", substring(s, 0, o));
		sframes = substring(s, o + 6, strlen(s) - o - 6);
		f = stof(sframes) + 1;
		db_put(tempdb, sname, ftos(max(f, stof(db_get(tempdb, sname)))));
	}
	search_end(dh);
}

void WaypointSprite_Load()
{
	waypointsprite_fadedistance = vlen(mi_scale);
	waypointsprite_normdistance = autocvar_g_waypointsprite_normdistance;
	waypointsprite_minscale = autocvar_g_waypointsprite_minscale;
	waypointsprite_minalpha = autocvar_g_waypointsprite_minalpha;
	waypointsprite_distancealphaexponent = autocvar_g_waypointsprite_distancealphaexponent;
	waypointsprite_timealphaexponent = autocvar_g_waypointsprite_timealphaexponent;
	waypointsprite_scale = autocvar_g_waypointsprite_scale;
	waypointsprite_fontsize = autocvar_g_waypointsprite_fontsize;
	waypointsprite_edgefadealpha = autocvar_g_waypointsprite_edgefadealpha;
	waypointsprite_edgefadescale = autocvar_g_waypointsprite_edgefadescale;
	waypointsprite_edgefadedistance = autocvar_g_waypointsprite_edgefadedistance;
	waypointsprite_edgeoffset_bottom = autocvar_g_waypointsprite_edgeoffset_bottom;
	waypointsprite_edgeoffset_left = autocvar_g_waypointsprite_edgeoffset_left;
	waypointsprite_edgeoffset_right = autocvar_g_waypointsprite_edgeoffset_right;
	waypointsprite_edgeoffset_top = autocvar_g_waypointsprite_edgeoffset_top;
	waypointsprite_crosshairfadealpha = autocvar_g_waypointsprite_crosshairfadealpha;
	waypointsprite_crosshairfadescale = autocvar_g_waypointsprite_crosshairfadescale;
	waypointsprite_crosshairfadedistance = autocvar_g_waypointsprite_crosshairfadedistance;
	waypointsprite_distancefadealpha = autocvar_g_waypointsprite_distancefadealpha;
	waypointsprite_distancefadescale = autocvar_g_waypointsprite_distancefadescale;
	waypointsprite_distancefadedistance = waypointsprite_fadedistance * autocvar_g_waypointsprite_distancefadedistancemultiplier;
	waypointsprite_alpha = autocvar_g_waypointsprite_alpha * (1 - autocvar__menu_alpha);

	if(!waypointsprite_initialized)
	{
		WaypointSprite_Load_Frames(".tga");
		WaypointSprite_Load_Frames(".jpg");
		waypointsprite_initialized = true;
	}

	waypointsprite_count = waypointsprite_newcount;
	waypointsprite_newcount = 0;
}
