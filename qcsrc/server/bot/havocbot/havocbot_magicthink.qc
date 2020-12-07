.float havocbot_nextmagicthink;

void CmdIterSpellForward(entity player);
void CmdIterSpellBack(entity player);
float CastSpellByName(float isscroll, entity caster, string spellname);
void ReadSpellByName (entity caster, float type, string spellname);
float PlayerCanDoMagic (entity player);

.string cmdcurrentspell;

void havocbot_castmagic()
{

	if (random() > 0.5)
		CmdIterSpellForward(self);
	
	if (random() > 0.5)
		CmdIterSpellForward(self);
		
	if (random() > 0.5)
		CmdIterSpellBack(self);
		
			if(!self.frozen)
			if(!self.freezetag_frozen)
			if(!self.stoned)
			if(self.prisonerlevel != 3)
			if(self.deadflag == DEAD_NO)
			if(self.health > 0)
			if(self.nextspell < time)
			{
					self.nextspell = CastSpellByName(0, self, self.cmdcurrentspell);
					if (self.rtnvl2 == 0) //Woubld be set to 1 if we had the spell.
					{
						//Lets see if we have the scroll instead.
						ReadSpellByName(self, 0, self.cmdcurrentspell);
					}
			}
}

void havocbot_magicthink()
{
	local float mytest;
	
	if (autocvar_bot_nofire)
		return;
		
	if (self.havocbot_nextmagicthink < time)
	{
		//Good
	} else {
		return;
	}
	
	mytest = PlayerCanDoMagic(self);
	if (mytest == 2) {
		//Have scrolls, Continue
	} else if (mytest == 1 && self.mana >= autocvar_bot_ai_magic_minmana) {
		//Know magic and has mana, continue
	} else {
		self.havocbot_nextmagicthink = self.havocbot_nextmagicthink + autocvar_bot_ai_magic_thinkinterval;
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
		//Magic perhaps
	} else {
		self.havocbot_nextmagicthink = self.havocbot_nextmagicthink + autocvar_bot_ai_magic_thinkinterval;
		return;
	}
	
	if (self.havocbot_nextmagicthink < time) {
		//Continue
	} else {
		return;
	}
		
	if ((self.stat_blinded > 99) || (self.stat_bangflash > 99) || (self.stat_nukeflash > 99))
	{
		//Can't See, Usually won't shoot
		self.havocbot_nextmagicthink = self.havocbot_nextmagicthink + 2;
		return;
		
	} else if (((self.stat_blinded > 80) || (self.stat_bangflash > 80) || (self.stat_nukeflash > 80))
	&& (random() > 0.02))
	{
		//Can't See Well, Usually won't shoot
		self.havocbot_nextmagicthink = self.havocbot_nextmagicthink + 2;
		return;
	}
				
	if (self.enemy && (vlen(self.enemy.origin - self.origin) < autocvar_bot_ai_magic_range))
	{		
		if (!bot_shouldattack(self.enemy))
		{
			// enemy died or something, find a new target
			//in choose enemy
		} else if (random() < 0.1) {
			//Magic!
			havocbot_castmagic();
		}
	}
}


