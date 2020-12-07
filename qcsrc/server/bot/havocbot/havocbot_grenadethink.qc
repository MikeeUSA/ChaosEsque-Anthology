.float havocbot_nextnadethink;
//.float havocbot_buryamine;
.float havocbot_nextburythink;
.float havocbot_releasenadetime;
.float havocbot_nextminesearchthink;
.float havocbot_nextdropmine;
.float havocbot_searchforunburiedmines;

void CmdBuryAllInRadius(entity e, float srchrad);

float havocbot_searchforfriendlymineinradius(entity e, float srchrad)
{
	entity f;
	f = findradius(e.origin, srchrad);
  	while(f)
  	{
		if (f.classname == "mine")
		{
			if (f.realowner == e) {
				return TRUE;
			}
			else if(teamplay && e.team == f.realowner.team && f.canbeburied < 2) {
				return TRUE;
			}
		}
    		f = f.chain;
  	}
	return FALSE;
}

float havocbot_findmineinradius(entity e, float srchrad)
{
	entity f;
	f = findradius(e.origin, srchrad);
  	while(f)
  	{
		if (f.classname == "mine")
		{
			if (f.realowner == e) {
				//print("found own mine too close\n");
				if (f.canbeburied < 2) {
					//print("trying to bury\n");
					CmdBuryAllInRadius(e, srchrad);
				}
				return TRUE;
			}
			else if(teamplay && e.team == f.realowner.team && f.canbeburied < 2) {
				//print("found team mine, will just try to bury\n");
				CmdBuryAllInRadius(e, srchrad);
			}
		}
    		f = f.chain;
  	}
	return FALSE;
}

float havocbot_findunburiedmineinradius(entity e, float srchrad)
{
	entity f;
	f = findradius(e.origin, srchrad);
  	while(f)
  	{
		if (f.classname == "mine")
		{
			if (f.realowner == e) {
				//print("Found own mine\n");
				if (f.canbeburied < 2) {
					//print("Trying to bury\n");
					CmdBuryAllInRadius(e, srchrad);
					return TRUE;
				}
			}
			else if(teamplay && e.team == f.realowner.team && f.canbeburied < 2) {
				//print("Found team mine, will just try to bury\n");
				CmdBuryAllInRadius(e, srchrad);
			}
		}
    		f = f.chain;
  	}
	return FALSE;
}

void havocbot_trytoburymines()
{	
	if(self.havocbot_nextminesearchthink > time)
	{
		return;
	} else {
		if (self.havocbot_searchforunburiedmines < 0) {
			self.havocbot_searchforunburiedmines = 0;
		}
	
		if(!self.frozen)
		if(!self.freezetag_frozen)
		if(!self.stoned)
		if(self.deadflag == DEAD_NO)
		if(self.health >= 1)
		if(!(self.prisonerlevel == 3))
		if((!(self.prisonerlevel > 1)) || self.bot_aggresskill > random())
		if(!self.handcuffed || self.bot_aggresskill > random())
		{
			if not (self.havocbot_searchforunburiedmines) {
				if (havocbot_searchforfriendlymineinradius(self, 1024))
				{	
					//print("Found some to bury, will check again soon\n");
					self.havocbot_searchforunburiedmines = 0.2;
					self.havocbot_nextminesearchthink = time + 1;
				} else {
					//print("Will wait some time till next search\n");
					self.havocbot_nextminesearchthink = time + 5;
				}
				return;
			} else {
				//print("searching for mines to bury\n");
				//print(ftos(self.havocbot_searchforunburiedmines), "mineslaypsudocounter C\n");
				self.havocbot_searchforunburiedmines = self.havocbot_searchforunburiedmines - 0.1;
				if (havocbot_findunburiedmineinradius(self, 128)) {
					self.havocbot_searchforunburiedmines = self.havocbot_searchforunburiedmines + 0.25;
					if (self.havocbot_searchforunburiedmines < 0) {
						self.havocbot_searchforunburiedmines = 0;
					}
					//If all our mines we know of, we know of have been buried, no need to search
				}
				self.havocbot_nextminesearchthink = time + 0.125;
			}
		}
	}
}

void havocbot_decidenade()
{
	local float grandvar;
	grandvar = random();
	
	//print("deciding on nade\n");
		
	if ((self.grenades || self.fragnades) && ((grandvar > autocvar_bot_ai_nades_grenadechoose) ||
	(!self.flashbangs && !self.smokenades)))
	{
		if (!self.grenades) {
			self.nadeselected = 5;
		} else if (!self.fragnades) {
			self.nadeselected = 0;
		} else {
			if (random() > 0.5) {
				self.nadeselected = 5;
			} else {
				self.nadeselected = 0;
			}
		}
	} else if (self.flashbangs
	&& ((self.smokenades && grandvar > autocvar_bot_ai_nades_flashbangchoose) || (!self.smokenades)))
	{
		self.nadeselected = 1;
	} else if (self.smokenades) {
		self.nadeselected = 2;
	}
}

void havocbot_decidemine()
{
	//print("deciding on mine\n");
	if (self.landmines && self.atmines)
	{
		if (random() > autocvar_bot_ai_nades_atmine)
		{
			//ATMine
			self.nadeselected = 4;
		} else {
			//Landmine
			self.nadeselected = 3;
		}
	} else if (self.landmines) {
		self.nadeselected = 3;
	} else if (self.atmines) {
		self.nadeselected = 4;
	}
}

////This code didn't workout well, bots were too far away by the time the
////mines were on the ground in almost all cases (sometimes the bot stood still
////rarely though, doing havocbot_trytoburymines often instead if we placed any mines
//void havocbot_burymine()
//{
//	if ((!self.havocbot_buryamine)
//	|| (self.havocbot_nextburythink < time))
//	{
//		return;
//	} else {
//		print("attempting to bury mine\n");
//		CmdBuryAllInRadius(self, 128); //Normal 64, bots get a pass
//		self.havocbot_buryamine = self.havocbot_buryamine - 1;
//		if (self.havocbot_buryamine > 1) {
//			self.havocbot_nextburythink = time + 0.2;
//		}
//		if (self.havocbot_buryamine < 1) {
//			self.havocbot_buryamine = 0; //Just in case
//		}
//	}
//}

void havocbot_naderelease()
{	if (self.button16)
	if (self.havocbot_releasenadetime > time)
	{
		if(!self.frozen)
		if(!self.freezetag_frozen)
		if(!self.stoned)
		if(self.deadflag == DEAD_NO)
		if(self.health >= 1)
		if(!(self.prisonerlevel == 3))
		if((!(self.prisonerlevel > 1)) || self.bot_aggresskill > random())
		if(!self.handcuffed || self.bot_aggresskill > random())
		{
				//print(" nade trowwwwww\n");
				self.button16 = 0;
		}
	}
}

void havocbot_grenadethink()
{
	if not(g_nades)
		return;
		
	if (autocvar_bot_nofire)
		return;
	
	havocbot_naderelease();
	havocbot_trytoburymines();

	
	if not(self.grenades || self.fragnades || self.flashbangs || self.smokenades
	|| self.landmines || self.atmines)
	{
		return;
	}
		
	//if (self.havocbot_nextnadethink < time || self.havocbot_buryamine)
	if (self.havocbot_nextnadethink < time)
	{
		//Good
	} else {
		return;
	}
			
	if(!self.frozen)
	if(!self.freezetag_frozen)
	if(!self.stoned)
	if(self.deadflag == DEAD_NO)
	if(self.health >= 1)
	if(!(self.prisonerlevel == 3))
	if((!(self.prisonerlevel > 1)) || self.bot_aggresskill > random())
	if(!self.handcuffed || self.bot_aggresskill > random())
	{
		//Nade perhaps
	} else {
		self.havocbot_nextnadethink = self.havocbot_nextnadethink + autocvar_bot_ai_nades_thinkinterval;
		return;
	}
		
	////By the time the mine hit the ground the bots were far away, thus that way didn't work
	//havocbot_burymine();
	
	if (self.button16 && self.havocbot_releasenadetime > time)
	{
		//print(" nade trow\n");
		self.button16 = 0;
	}
	
	if (self.havocbot_nextnadethink < time) {
		//Continue
	} else {
		return;
	}
		
	if ((self.stat_blinded > 99) || (self.stat_bangflash > 99) || (self.stat_nukeflash > 99))
	{
		//Can't See, Usually won't shoot
		self.havocbot_nextnadethink = self.havocbot_nextnadethink + 2;
		return;
		
	} else if (((self.stat_blinded > 80) || (self.stat_bangflash > 80) || (self.stat_nukeflash > 80))
	&& (random() > 0.02))
	{
		//Can't See Well, Usually won't shoot
		self.havocbot_nextnadethink = self.havocbot_nextnadethink + 2;
		return;
	}
				
	if (self.enemy && (vlen(self.enemy.origin - self.origin) < autocvar_bot_ai_nades_throwrange))
	{		
		if (!bot_shouldattack(self.enemy))
		{
			// enemy died or something, find a new target
			//in choose enemy
		} else if (random() < autocvar_bot_ai_nades_throwrate) {
			//Throw nade
			havocbot_decidenade();
			self.button16 = 1;
			self.havocbot_releasenadetime = time + (autocvar_g_nades_nade_lifetime*autocvar_bot_ai_nades_throwwaitrate*random());
		}
	} else if (self.landmines || self.atmines && (self.havocbot_nextdropmine < time)) {
		if (random() < autocvar_bot_ai_nades_minedroprate)
		if not(havocbot_findmineinradius(self, 128))
		{
			//Drop mine
			havocbot_decidemine();
			self.button16 = 1;
			self.havocbot_releasenadetime = time + 0.1;
			self.havocbot_searchforunburiedmines = self.havocbot_searchforunburiedmines + 1;
			
			///////////////////////////////////////////////////////////
			////Bots were too far away before the mine hit the ground
			////for this code to be effective
			//if not(self.havocbot_buryamine) {
			//	self.havocbot_buryamine = 4; //Try 4 times
			//	self.havocbot_nextburythink = time + 0.12;
			//}
			///////////////////////////////////////////////////////////
			
			//Depending on how many mines have, conserve
			if (self.landmines + self.atmines <= autocvar_bot_ai_nades_minescarse)
			{
				self.havocbot_nextdropmine = time + autocvar_bot_ai_nades_minedropwaitscarse;
			} else if (self.landmines + self.atmines <= autocvar_bot_ai_nades_minefew)
			{
				self.havocbot_nextdropmine = time + autocvar_bot_ai_nades_minedropwaitfew;
			} else {
				self.havocbot_nextdropmine = time + autocvar_bot_ai_nades_minedropwait;
			}
		}
	}
}


