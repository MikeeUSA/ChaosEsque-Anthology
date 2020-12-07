/*
.vector fx_start;
.vector fx_end;
.float  fx_with;
.string fx_texture;
.float  fx_lifetime;

void SUB_Remove()
{ remove(self); }

void b_draw()
{
    //Draw_CylindricLine(self.fx_start, self.fx_end, self.fx_with, self.fx_texture, 0, time * 3, '1 1 1', 0.7, DRAWFLAG_ADDITIVE, view_origin);
    Draw_CylindricLine(self.fx_start, self.fx_end, self.fx_with, self.fx_texture, (self.fx_with/256), 0, '1 1 1', 1, DRAWFLAG_ADDITIVE, view_origin);

}
void b_make(vector s,vector e, string t,float l,float z)
{
    entity b;
    b = spawn();
    b.fx_texture = t;
    b.fx_start = s;
    b.fx_end = e;
    b.fx_with = z;
    b.think = SUB_Remove;
    b.nextthink = time + l;
	b.draw = b_draw;

	//b.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
}
*/


void cl_effetcs_lightningarc_setcolor(vector mycolor)
{
	if (autocvar_cl_allow_lightningchange) {
    		localcmd(strcat("\nr_lightningbeam_color_red ", ftos(mycolor_x),"\n"));
    		localcmd(strcat("\nr_lightningbeam_color_green ", ftos(mycolor_y),"\n"));
    		localcmd(strcat("\nr_lightningbeam_color_blue ", ftos(mycolor_z),"\n"));	
	}
}


void cl_effetcs_lightningarc_setcolor_blue(void)
{
	//print("blue\n");
	cl_effetcs_lightningarc_setcolor('0.5 0.7 1');
}

void cl_effetcs_lightningarc_setcolor_cyan(void)
{
	//print("cyan\n");
	cl_effetcs_lightningarc_setcolor('0.5 0.75 0.7');
}

void cl_effetcs_lightningarc_setcolor_purple(void)
{
	//print("purple\n");
	cl_effetcs_lightningarc_setcolor('0.7 0.55 0.7');
}

void cl_effetcs_lightningarc_setcolor_darkblue(void)
{
	//print("darkblue\n");
	cl_effetcs_lightningarc_setcolor('0.4 0.4 0.7');
}

void cl_effetcs_lightningarc_setcolor_white(void)
{
	//print("white\n");
	cl_effetcs_lightningarc_setcolor('0.7 0.7 0.7');
}

void cl_effetcs_lightningarc(vector from, vector to,float seglength,float drifts,float drifte,float branchfactor,float branchfactor_add)
{
    vector direction,dirnew, pos, pos_l;
    float length, steps, steplength, i,drift;

    length     = vlen(from - to);
    if(length < 1)
        return;

	cl_effetcs_lightningarc_setcolor_white(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do

    steps      = floor(length / seglength);
    if(steps < 1)
    {
        te_lightning1(world,from,to);
        return;
    }

    steplength = length / steps;
    direction  = normalize(to - from);
    pos_l = from;
    if(length > seglength)
    {
        for(i = 1; i < steps; i += 1)
        {
            drift = drifts * (1 - (i / steps)) + drifte * (i / steps);
            dirnew = normalize(direction * (1 - drift) + randomvec() * drift);
            pos = pos_l +  dirnew * steplength;
            te_lightning1(world,pos_l,pos);
            if(random() < branchfactor)
                cl_effetcs_lightningarc(pos, pos + (dirnew * length * 0.25),seglength,drifts,drifte,min(branchfactor + branchfactor_add,1),branchfactor_add);

            pos_l = pos;
        }
        te_lightning1(world,pos_l,to);

    }
    else
        te_lightning1(world,from,to);

}

void Net_ReadLightningarc()
{
	vector from, to;
	
	cl_effetcs_lightningarc_setcolor_white(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do

    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    if(autocvar_cl_effects_lightningarc_simple)
    {
        te_lightning1(world,from,to);
    }
    else
    {
        float seglength, drifts, drifte, branchfactor, branchfactor_add;

        seglength        = autocvar_cl_effects_lightningarc_segmentlength;
        drifts           = autocvar_cl_effects_lightningarc_drift_start;
        drifte           = autocvar_cl_effects_lightningarc_drift_end;
        branchfactor     = autocvar_cl_effects_lightningarc_branchfactor_start;
        branchfactor_add = autocvar_cl_effects_lightningarc_branchfactor_add;

        cl_effetcs_lightningarc(from,to,seglength,drifts,drifte,branchfactor,branchfactor_add);
    }

}

//FireArc
void cl_effetcs_firearc(vector from, vector to,float seglength,float drifts,float drifte,float branchfactor,float branchfactor_add)
{
    vector direction,dirnew, pos, pos_l;
    float length, steps, steplength, i,drift;
    local float effectnum;
    effectnum = particleeffectnum("fireball");

    length     = vlen(from - to);
    if(length < 1)
        return;

    steps      = floor(length / seglength);
    if(steps < 1)
    {
        trailparticles(world, effectnum, from, to);
        return;
    }

    steplength = length / steps;
    direction  = normalize(to - from);
    pos_l = from;
    if(length > seglength)
    {
        for(i = 1; i < steps; i += 1)
        {
            drift = drifts * (1 - (i / steps)) + drifte * (i / steps);
            dirnew = normalize(direction * (1 - drift) + randomvec() * drift);
            pos = pos_l +  dirnew * steplength;
            trailparticles(world, effectnum, pos_l,pos);
            if(random() < branchfactor)
                cl_effetcs_firearc(pos, pos + (dirnew * length * 0.25),seglength,drifts,drifte,min(branchfactor + branchfactor_add,1),branchfactor_add);

            pos_l = pos;
        }
        trailparticles(world, effectnum, from, to);

    }
    else
        trailparticles(world, effectnum, from, to);

}

void Net_ReadFirearc()
{
	vector from, to;
	local float effectnum;
	effectnum = particleeffectnum("fireball");

    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    if(autocvar_cl_effects_lightningarc_simple)
    {
        trailparticles(world, effectnum, from, to);
    }
    else
    {
        float seglength, drifts, drifte, branchfactor, branchfactor_add;

        seglength        = autocvar_cl_effects_lightningarc_segmentlength;
        drifts           = autocvar_cl_effects_lightningarc_drift_start;
        drifte           = autocvar_cl_effects_lightningarc_drift_end;
        branchfactor     = autocvar_cl_effects_lightningarc_branchfactor_start;
        branchfactor_add = autocvar_cl_effects_lightningarc_branchfactor_add;

        cl_effetcs_firearc(from,to,seglength,drifts,drifte,branchfactor,branchfactor_add);
    }

}

//This is for different coloured lightning. Not really per-entity, but we try,
//The engine only knows to give lightning the colour in the vars, so we 
//switch on and off, but if there are diff lighnings going, it will 
//prob affect the allready existing ones in the render

//float autocvar_cl_saved_r_lightningbeam_color_red;
//float autocvar_cl_saved_r_lightningbeam_color_green;
//float autocvar_cl_saved_r_lightningbeam_color_blue;
//void cl_effetcs_lightningarc_savecolor (void)
//{
//    autocvar_cl_saved_r_lightningbeam_color_red  = cvar("r_lightningbeam_color_red");
//    autocvar_cl_saved_r_lightningbeam_color_green  = cvar("r_lightningbeam_color_green");
//    autocvar_cl_saved_r_lightningbeam_color_blue  = cvar("r_lightningbeam_color_blue");
//}
//void cl_effetcs_lightningarc_resetcolor(void)
//{
//    localcmd(strcat("\nr_lightningbeam_color_red ", ftos(autocvar_cl_saved_r_lightningbeam_color_red),"\n"));
//    localcmd(strcat("\nr_lightningbeam_color_green ", ftos(autocvar_cl_saved_r_lightningbeam_color_green),"\n"));
//    localcmd(strcat("\nr_lightningbeam_color_blue ", ftos(autocvar_cl_saved_r_lightningbeam_color_blue),"\n"));	
//}
//The above were written in hopes that a beam sent would keep it's color and then we could reset.
//Turned out not to be the case.
//Keeping here so you won't retry that
//So now we just set a color before calling
//Try to keep them white/blue/etc energy looking, as if the use the wrong color
//(multiple people using diff lighning effect, one wins the renderer), it won't look out of place
//Per beam immutable color would require engine edits

void cl_effetcs_lightningarcb(vector from, vector to,float seglength,float drifts,float drifte,float branchfactor,float branchfactor_add)
{
    vector direction,dirnew, pos, pos_l;
    float length, steps, steplength, i,drift;

    length     = vlen(from - to);
    if(length < 1)
        return;
	
    cl_effetcs_lightningarc_setcolor_blue(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do
	
    steps      = floor(length / seglength);
    if(steps < 1)
    {
        te_lightning1(world,from,to);
        return;
    }

    steplength = length / steps;
    direction  = normalize(to - from);
    pos_l = from;
    if(length > seglength)
    {
        for(i = 1; i < steps; i += 1)
        {
            drift = drifts * (1 - (i / steps)) + drifte * (i / steps);
            dirnew = normalize(direction * (1 - drift) + randomvec() * drift);
            pos = pos_l +  dirnew * steplength;
            te_lightning1(world,pos_l,pos);
            if(random() < branchfactor)
                cl_effetcs_lightningarcb(pos, pos + (dirnew * length * 0.25),seglength,drifts,drifte,min(branchfactor + branchfactor_add,1),branchfactor_add);

            pos_l = pos;
        }
        te_lightning1(world,pos_l,to);
	

    }
    else
        te_lightning1(world,from,to);

}

void Net_ReadLightningarcb()
{
	vector from, to;
	
    cl_effetcs_lightningarc_setcolor_blue(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do

    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    if(autocvar_cl_effects_lightningarc_simple)
    {
        te_lightning1(world,from,to);
    }
    else
    {
        float seglength, drifts, drifte, branchfactor, branchfactor_add;

        seglength        = autocvar_cl_effects_lightningarc_segmentlength;
        drifts           = autocvar_cl_effects_lightningarc_drift_start;
        drifte           = autocvar_cl_effects_lightningarc_drift_end;
        branchfactor     = autocvar_cl_effects_lightningarc_branchfactor_start;
        branchfactor_add = autocvar_cl_effects_lightningarc_branchfactor_add;

        cl_effetcs_lightningarcb(from,to,seglength,drifts,drifte,branchfactor,branchfactor_add);
    }

}
//Cyan

void cl_effetcs_lightningarcc(vector from, vector to,float seglength,float drifts,float drifte,float branchfactor,float branchfactor_add)
{
    vector direction,dirnew, pos, pos_l;
    float length, steps, steplength, i,drift;

    length     = vlen(from - to);
    if(length < 1)
        return;
	
    cl_effetcs_lightningarc_setcolor_cyan(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do
	
    steps      = floor(length / seglength);
    if(steps < 1)
    {
        te_lightning1(world,from,to);
        return;
    }

    steplength = length / steps;
    direction  = normalize(to - from);
    pos_l = from;
    if(length > seglength)
    {
        for(i = 1; i < steps; i += 1)
        {
            drift = drifts * (1 - (i / steps)) + drifte * (i / steps);
            dirnew = normalize(direction * (1 - drift) + randomvec() * drift);
            pos = pos_l +  dirnew * steplength;
            te_lightning1(world,pos_l,pos);
            if(random() < branchfactor)
                cl_effetcs_lightningarcc(pos, pos + (dirnew * length * 0.25),seglength,drifts,drifte,min(branchfactor + branchfactor_add,1),branchfactor_add);

            pos_l = pos;
        }
        te_lightning1(world,pos_l,to);
	

    }
    else
        te_lightning1(world,from,to);

}

void Net_ReadLightningarcc()
{
	vector from, to;
	
    cl_effetcs_lightningarc_setcolor_cyan(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do

    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    if(autocvar_cl_effects_lightningarc_simple)
    {
        te_lightning1(world,from,to);
    }
    else
    {
        float seglength, drifts, drifte, branchfactor, branchfactor_add;

        seglength        = autocvar_cl_effects_lightningarc_segmentlength;
        drifts           = autocvar_cl_effects_lightningarc_drift_start;
        drifte           = autocvar_cl_effects_lightningarc_drift_end;
        branchfactor     = autocvar_cl_effects_lightningarc_branchfactor_start;
        branchfactor_add = autocvar_cl_effects_lightningarc_branchfactor_add;

        cl_effetcs_lightningarcc(from,to,seglength,drifts,drifte,branchfactor,branchfactor_add);
    }

}

//DarkBlue

void cl_effetcs_lightningarcd(vector from, vector to,float seglength,float drifts,float drifte,float branchfactor,float branchfactor_add)
{
    vector direction,dirnew, pos, pos_l;
    float length, steps, steplength, i,drift;

    length     = vlen(from - to);
    if(length < 1)
        return;
	
    cl_effetcs_lightningarc_setcolor_darkblue(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do
	
    steps      = floor(length / seglength);
    if(steps < 1)
    {
        te_lightning1(world,from,to);
        return;
    }

    steplength = length / steps;
    direction  = normalize(to - from);
    pos_l = from;
    if(length > seglength)
    {
        for(i = 1; i < steps; i += 1)
        {
            drift = drifts * (1 - (i / steps)) + drifte * (i / steps);
            dirnew = normalize(direction * (1 - drift) + randomvec() * drift);
            pos = pos_l +  dirnew * steplength;
            te_lightning1(world,pos_l,pos);
            if(random() < branchfactor)
                cl_effetcs_lightningarcd(pos, pos + (dirnew * length * 0.25),seglength,drifts,drifte,min(branchfactor + branchfactor_add,1),branchfactor_add);

            pos_l = pos;
        }
        te_lightning1(world,pos_l,to);
	

    }
    else
        te_lightning1(world,from,to);

}

void Net_ReadLightningarcd()
{
	vector from, to;
	
    cl_effetcs_lightningarc_setcolor_darkblue(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do

    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    if(autocvar_cl_effects_lightningarc_simple)
    {
        te_lightning1(world,from,to);
    }
    else
    {
        float seglength, drifts, drifte, branchfactor, branchfactor_add;

        seglength        = autocvar_cl_effects_lightningarc_segmentlength;
        drifts           = autocvar_cl_effects_lightningarc_drift_start;
        drifte           = autocvar_cl_effects_lightningarc_drift_end;
        branchfactor     = autocvar_cl_effects_lightningarc_branchfactor_start;
        branchfactor_add = autocvar_cl_effects_lightningarc_branchfactor_add;

        cl_effetcs_lightningarcd(from,to,seglength,drifts,drifte,branchfactor,branchfactor_add);
    }

}

//Purpleish

void cl_effetcs_lightningarcp(vector from, vector to,float seglength,float drifts,float drifte,float branchfactor,float branchfactor_add)
{
    vector direction,dirnew, pos, pos_l;
    float length, steps, steplength, i,drift;

    length     = vlen(from - to);
    if(length < 1)
        return;
	
    cl_effetcs_lightningarc_setcolor_purple(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do
	
    steps      = floor(length / seglength);
    if(steps < 1)
    {
        te_lightning1(world,from,to);
        return;
    }

    steplength = length / steps;
    direction  = normalize(to - from);
    pos_l = from;
    if(length > seglength)
    {
        for(i = 1; i < steps; i += 1)
        {
            drift = drifts * (1 - (i / steps)) + drifte * (i / steps);
            dirnew = normalize(direction * (1 - drift) + randomvec() * drift);
            pos = pos_l +  dirnew * steplength;
            te_lightning1(world,pos_l,pos);
            if(random() < branchfactor)
                cl_effetcs_lightningarcp(pos, pos + (dirnew * length * 0.25),seglength,drifts,drifte,min(branchfactor + branchfactor_add,1),branchfactor_add);

            pos_l = pos;
        }
        te_lightning1(world,pos_l,to);
	

    }
    else
        te_lightning1(world,from,to);

}

void Net_ReadLightningarcp()
{
	vector from, to;
	
    cl_effetcs_lightningarc_setcolor_purple(); //Yes not the best, but otherwise we need to do engine edits to send beam color per beam, currently it is a global so we do what we can do

    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    if(autocvar_cl_effects_lightningarc_simple)
    {
        te_lightning1(world,from,to);
    }
    else
    {
        float seglength, drifts, drifte, branchfactor, branchfactor_add;

        seglength        = autocvar_cl_effects_lightningarc_segmentlength;
        drifts           = autocvar_cl_effects_lightningarc_drift_start;
        drifte           = autocvar_cl_effects_lightningarc_drift_end;
        branchfactor     = autocvar_cl_effects_lightningarc_branchfactor_start;
        branchfactor_add = autocvar_cl_effects_lightningarc_branchfactor_add;

        cl_effetcs_lightningarcp(from,to,seglength,drifts,drifte,branchfactor,branchfactor_add);
    }

}
