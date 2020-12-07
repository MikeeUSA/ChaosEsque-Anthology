
entity PlayerIsInFilth(entity player)
{
		local entity entm;
		entm = findchainfloat(isfilth, 1);
    		while (entm)
    		{
    		    //////fithareasexist = filthareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, player.absmin, player.absmax))
		    {
		    	return entm;
		    }
    		    entm = entm.chain;
    		}
			
		return world;
}

float TransferSmellsCalculateRate (entity player, entity mytsent)
{
	float mytransfersmellrate;
	mytransfersmellrate = 0;
	
	if (player.waterlevel != WATERLEVEL_NONE) {
		if (player.watertype == CONTENT_LAVA && mytsent.transfer_smell_rate_lava) {
			mytransfersmellrate = mytsent.transfer_smell_rate_lava;
		
			//print("TSR:Lava\n");
		
		} else if (player.watertype == CONTENT_SLIME && mytsent.transfer_smell_rate_slime) {
			mytransfersmellrate = mytsent.transfer_smell_rate_slime;
			
			//print("TSR:SLIME\n");
		
		} else if (player.watertype == CONTENT_WATER && mytsent.transfer_smell_rate_water) {
			mytransfersmellrate = mytsent.transfer_smell_rate_water;
			
			//print("TSR:WATER\n");
		} else {
			//Fallback
			if (mytsent.transfer_smell_rate_liquid) {
				mytransfersmellrate = mytsent.transfer_smell_rate_liquid;
			
				//print("TSR:liquid\n");
				
				//print("TS: ", ftos(mytransfersmellrate),"0\n");
			}
		}
	} else {
		if (mytsent.transfer_smell_rate_any) {
			mytransfersmellrate = mytsent.transfer_smell_rate_any;
			
			//print("TSR: any\n");
		}
	}
	
	//print("TS: ", ftos(mytransfersmellrate),"1\n");
	
	if not (mytransfersmellrate) {
		//print("TSR::Return - No transferrate\n");
		return 0;
	}
	
	//print("TS: ", ftos(mytransfersmellrate),"2\n");

	if (player.waterlevel == WATERLEVEL_SUBMERGED) {
		//keep
			//print("TSR:: Submerged\n");
	} else if (player.waterlevel == WATERLEVEL_SWIMMING) {
		mytransfersmellrate = mytransfersmellrate * 0.5;
			//print("TSR:: Swimming\n");
	} else if (player.waterlevel == WATERLEVEL_WETFEET) {
		mytransfersmellrate = mytransfersmellrate * 0.2;
			//print("TSR:: Wetfeet\n");
	}
	
	//print("TS: ", ftos(mytransfersmellrate),"3\n");
	
	return (mytransfersmellrate);
}


float TransferSmells (entity player, entity mytsent)
{
	float mywasinfilthliquidlastmetabolize;
	float mytransfersmellrate;
	mywasinfilthliquidlastmetabolize = 0;
	mytransfersmellrate = TransferSmellsCalculateRate(player, mytsent);
	
	//print("TS: ", ftos(mytransfersmellrate),"\n");
	
	if (mytransfersmellrate) {
	  if (mytransfersmellrate > 0) {
		if (mytsent.smell_acrid && (player.smell_acrid < mytsent.smell_acrid)) { player.smell_acrid = bound(0, player.smell_acrid + (mytsent.smell_acrid * mytransfersmellrate), mytsent.smell_acrid); }
		if (mytsent.smell_alcohol && (player.smell_alcohol < mytsent.smell_alcohol)) { player.smell_alcohol =  bound(0, player.smell_alcohol + (mytsent.smell_alcohol * mytransfersmellrate), mytsent.smell_alcohol); }
		if (mytsent.smell_bodyodor && (player.smell_bodyodor < mytsent.smell_bodyodor)) { player.smell_bodyodor = bound(0, player.smell_bodyodor + (mytsent.smell_bodyodor * mytransfersmellrate), mytsent.smell_bodyodor); }
		if (mytsent.smell_cheeze && (player.smell_cheeze < mytsent.smell_cheeze)) { player.smell_cheeze = bound(0, player.smell_cheeze + (mytsent.smell_cheeze * mytransfersmellrate), mytsent.smell_cheeze); }
		if (mytsent.smell_earthy && (player.smell_earthy < mytsent.smell_earthy)) { player.smell_earthy = bound(0, player.smell_earthy + (mytsent.smell_earthy * mytransfersmellrate), mytsent.smell_earthy); }
		if (mytsent.smell_faeces && (player.smell_faeces < mytsent.smell_faeces)) { player.smell_faeces = bound(0, player.smell_faeces + (mytsent.smell_faeces * mytransfersmellrate), mytsent.smell_faeces); }
		if (mytsent.smell_garlic && (player.smell_garlic < mytsent.smell_garlic)) { player.smell_garlic = bound(0, player.smell_garlic + (mytsent.smell_garlic * mytransfersmellrate), mytsent.smell_garlic); }
		if (mytsent.smell_urine && (player.smell_urine < mytsent.smell_urine)) { player.smell_urine = bound(0, player.smell_urine + (mytsent.smell_urine * mytransfersmellrate), mytsent.smell_urine); }
		if (mytsent.smell_roses && (player.smell_roses < mytsent.smell_roses)) { player.smell_roses = bound(0, player.smell_roses + (mytsent.smell_roses * mytransfersmellrate), mytsent.smell_roses); }
		if (mytsent.smell_rottingflesh && (player.smell_rottingflesh < mytsent.smell_rottingflesh)) { player.smell_rottingflesh = bound(0, player.smell_rottingflesh + (mytsent.smell_rottingflesh * mytransfersmellrate), mytsent.smell_rottingflesh); }
	  
	  	if (mytsent.smell_faeces) {
			mywasinfilthliquidlastmetabolize = 1;
		} 
	  }
	}
	
	return mywasinfilthliquidlastmetabolize;
}



entity PlayerWaftDetermine(entity player, float myradfar, float myradclose, .float myevaluatedsmell)
{
		local entity enttop;
		local float mylastmost;
		local entity entm;
		enttop = world;
		mylastmost = 0;
		entm = findradius(player.origin, 512);
    		while (entm)
    		{
    		    if (entm.myevaluatedsmell > 0) {
		    if (entm != world) {
		    if (entm != player) {
		    	local float mydidfindent;
		    	if(boxesoverlap(entm.absmin, entm.absmax, player.absmin, player.absmax))
		    	{
		    		mydidfindent = 1;
		    	} else if (vlen(player.origin-entm.origin) < myradclose) {
		    		mydidfindent = 1;
		    	}
			
			if (entm.myevaluatedsmell > mylastmost) {
				enttop = entm;
			}
		    }
		    }
		    }
    		    entm = entm.chain;
    		}
		
		if (enttop != world) {
			return enttop;
		}
			
		return world;
}






void PlayerWaftOffendSmellFaecesWriteMsg (entity mysmellfaecesent, entity player)
{
	if (mysmellfaecesent.smell_faeces >= 3) {
		sprint(player, "The unrecountable stench of excrement chokes your thoughts\n");
	} else if (mysmellfaecesent.smell_faeces >= 2) {
		sprint(player, "An absolutely disgusting odour of faeces permeates all\n");
	} else if (mysmellfaecesent.smell_faeces >= 1.5) {
		sprint(player, "A disgusting odour of faeces is all around\n");
	} else if (mysmellfaecesent.smell_faeces >= 1) {
		sprint(player, "A sickening odour of faeces envelopes you\n");
	} else if (mysmellfaecesent.smell_faeces >= 0.5) {
		sprint(player, "The air is foul with the smell of fecal material\n");
	} else if (mysmellfaecesent.smell_faeces >= 0.25) {
		sprint(player, "You smell faeces\n");
	} else if (mysmellfaecesent.smell_faeces >= 0.1) {
		sprint(player, "You catch a whiff of excrement\n");
	} else if (mysmellfaecesent.smell_faeces >= 0.05) {
		sprint(player, "A faint odour of faeces is detectable\n");
	}
}

void PlayerWaftOffendSmellRottingFleshWriteMsg (entity mysmellrottingfleshent, entity player)
{
	if (mysmellrottingfleshent.smell_rottingflesh >= 2) {
		sprint(player, "The sickening putrid odour of rotting flesh offends all\n");
	} else if (mysmellrottingfleshent.smell_rottingflesh >= 1.2) {
		sprint(player, "The air is defiled\n");
	} else if (mysmellrottingfleshent.smell_rottingflesh >= 0.5) {
		sprint(player, "The air is foul with the stench of death\n");
	} else if (mysmellrottingfleshent.smell_rottingflesh >= 0.25) {
		sprint(player, "Rotting corpses must be in the vicinity\n");
	} else if (mysmellrottingfleshent.smell_rottingflesh >= 0.1) {
		sprint(player, "You notice the odour of decaying flesh\n");
	} else if (mysmellrottingfleshent.smell_rottingflesh >= 0.05) {
		sprint(player, "You detect a faint odour of putrid decay\n");
	}
}

void PlayerWaftOffendSmellBodyodorWriteMsg (entity mysmellbodyodorent, entity player)
{
	if (mysmellbodyodorent.species == SPECIES_ANIMAL) {
		if (mysmellbodyodorent.smell_bodyodor >= 2) {
			sprint(player, "The opressive musk of an animal permeates\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 2) {
			sprint(player, "An opressive animal stench lingers\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 1) {
			sprint(player, "There is a distasteful overabundance of animal odour present\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.5) {
			sprint(player, "The air is heavy with animal musk\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.25) {
			sprint(player, "You smell an animal\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.1) {
			sprint(player, "On the air there is a tinge of animal odour\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.05) {
			sprint(player, "A faint hint of an animal is detectable\n");
		}
	} else {
		if (mysmellbodyodorent.smell_bodyodor >= 2) {
			sprint(player, "The opressive stench of bodyodor permeates\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 2) {
			sprint(player, "An opressive stench of bodyodor lingers\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 1) {
			sprint(player, "There is a distasteful overabundance of bodyodor present\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.5) {
			sprint(player, "The air is heavy with bodyodor\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.25) {
			sprint(player, "You smell bodyodor\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.1) {
			sprint(player, "On the air there is a tinge of bodyodor present\n");
		} else if (mysmellbodyodorent.smell_bodyodor >= 0.05) {
			sprint(player, "A faint hint of bodyodor is detectable\n");
		}
	}
}

void PlayerWaftDelightSmellRosesWriteMsg (entity mysmellrosesent, entity player)
{
	local float mrnd;
	
	if (mysmellrosesent.smell_roses >= 0.5) {
		mrnd = random();
		if (mrnd > 0.75) 
			sprint(player, "The air lightened with the pleasantries of roses\n");
		else if (mrnd > 0.5) 
			sprint(player, "The air has a delightful redolence\n");
		else
			sprint(player, "The fragrance of rose petals regales\n");
			
	} else if (mysmellrosesent.smell_roses >= 0.25) {
		sprint(player, "You enjoy the rose scented air\n");
	} else if (mysmellrosesent.smell_roses >= 0.1) {
		sprint(player, "Delightful times come to mind as a waft of roses passes by\n");
	} else if (mysmellrosesent.smell_roses >= 0.05) {
		sprint(player, "A faint hint of roses brings the memory of delight\n");
	}
}

float PlayerWaftOffendFaeces (entity player)
{
	local entity mysmellfaecesent;
	mysmellfaecesent = world;

	mysmellfaecesent = PlayerWaftDetermine(player, 512, 128, smell_faeces);
	if (mysmellfaecesent) {
	  if (mysmellfaecesent != world) {
		if (player.nextwaft_smell_faeces_ent) {
			if (player.nextwaft_smell_faeces_ent != mysmellfaecesent) {
				if (mysmellfaecesent.smell_faeces > player.nextwaft_smell_faeces_amnt)
				{
					if (time > (player.nextwaft_smell_faeces_time+1)) {
						player.nextwaft_smell_faeces_ent = mysmellfaecesent;
						player.nextwaft_smell_faeces_amnt = mysmellfaecesent.smell_faeces;
						player.nextwaft_smell_faeces_time = time;
					
						PlayerWaftOffendSmellFaecesWriteMsg(mysmellfaecesent, player);
						return 1;
					}
				} else if (time > (player.nextwaft_smell_faeces_time+80)) {
						player.nextwaft_smell_faeces_ent = mysmellfaecesent;
						player.nextwaft_smell_faeces_amnt = mysmellfaecesent.smell_faeces;
						player.nextwaft_smell_faeces_time = time;
					
						PlayerWaftOffendSmellFaecesWriteMsg(mysmellfaecesent, player);
						return 1;
				}
			} else {
				if (time > (player.nextwaft_smell_faeces_time+60)) {
					player.nextwaft_smell_faeces_ent = mysmellfaecesent;
					player.nextwaft_smell_faeces_amnt = mysmellfaecesent.smell_faeces;
					player.nextwaft_smell_faeces_time = time;
					
					PlayerWaftOffendSmellFaecesWriteMsg(mysmellfaecesent, player);
					return 1;
				}
			}
		} else {
			player.nextwaft_smell_faeces_ent = mysmellfaecesent;
			player.nextwaft_smell_faeces_amnt = mysmellfaecesent.smell_faeces;
			player.nextwaft_smell_faeces_time = time;
					
			PlayerWaftOffendSmellFaecesWriteMsg(mysmellfaecesent, player);
			return 1;
		}
	  }
	}
	
	return 0;
}



float PlayerWaftOffendRottingflesh (entity player)
{
	local entity mysmellrottingfleshent;
	mysmellrottingfleshent = world;

	mysmellrottingfleshent = PlayerWaftDetermine(player, 512, 128, smell_rottingflesh);
	if (mysmellrottingfleshent) {
	  if (mysmellrottingfleshent != world) {
		if (player.nextwaft_smell_rottingflesh_ent) {
			if (player.nextwaft_smell_rottingflesh_ent != mysmellrottingfleshent) {
				if (mysmellrottingfleshent.smell_rottingflesh > player.nextwaft_smell_rottingflesh_amnt)
				{
					if (time > (player.nextwaft_smell_rottingflesh_time+2)) {
						player.nextwaft_smell_rottingflesh_ent = mysmellrottingfleshent;
						player.nextwaft_smell_rottingflesh_amnt = mysmellrottingfleshent.smell_rottingflesh;
						player.nextwaft_smell_rottingflesh_time = time;
					
						PlayerWaftOffendSmellRottingFleshWriteMsg(mysmellrottingfleshent, player);
						return 1;
					}
				} else if (time > (player.nextwaft_smell_rottingflesh_time+120)) {
						player.nextwaft_smell_rottingflesh_ent = mysmellrottingfleshent;
						player.nextwaft_smell_rottingflesh_amnt = mysmellrottingfleshent.smell_rottingflesh;
						player.nextwaft_smell_rottingflesh_time = time;
					
						PlayerWaftOffendSmellRottingFleshWriteMsg(mysmellrottingfleshent, player);
						return 1;
				}
			} else {
				if (time > (player.nextwaft_smell_rottingflesh_time+90)) {
					player.nextwaft_smell_rottingflesh_ent = mysmellrottingfleshent;
					player.nextwaft_smell_rottingflesh_amnt = mysmellrottingfleshent.smell_rottingflesh;
					player.nextwaft_smell_rottingflesh_time = time;
					
					PlayerWaftOffendSmellRottingFleshWriteMsg(mysmellrottingfleshent, player);
					return 1;
				}
			}
		} else {
			player.nextwaft_smell_rottingflesh_ent = mysmellrottingfleshent;
			player.nextwaft_smell_rottingflesh_amnt = mysmellrottingfleshent.smell_rottingflesh;
			player.nextwaft_smell_rottingflesh_time = time;
					
			PlayerWaftOffendSmellRottingFleshWriteMsg(mysmellrottingfleshent, player);
			return 1;
		}
	  }
	}
	
	return 0;
}







float PlayerWaftOffendBodyodor (entity player)
{
	local entity mysmellbodyodorent;
	mysmellbodyodorent = world;

	mysmellbodyodorent = PlayerWaftDetermine(player, 512, 128, smell_bodyodor);
	if (mysmellbodyodorent) {
	  if (mysmellbodyodorent != world) {
		if (player.nextwaft_smell_bodyodor_ent) {
			if (player.nextwaft_smell_bodyodor_ent != mysmellbodyodorent) {
				if (mysmellbodyodorent.smell_bodyodor > player.nextwaft_smell_bodyodor_amnt)
				{
					if (time > (player.nextwaft_smell_bodyodor_time+10)) {
						player.nextwaft_smell_bodyodor_ent = mysmellbodyodorent;
						player.nextwaft_smell_bodyodor_amnt = mysmellbodyodorent.smell_bodyodor;
						player.nextwaft_smell_bodyodor_time = time;
					
						PlayerWaftOffendSmellBodyodorWriteMsg(mysmellbodyodorent, player);
						return 1;
					}
				} else if (time > (player.nextwaft_smell_bodyodor_time+160)) {
						player.nextwaft_smell_bodyodor_ent = mysmellbodyodorent;
						player.nextwaft_smell_bodyodor_amnt = mysmellbodyodorent.smell_bodyodor;
						player.nextwaft_smell_bodyodor_time = time;
					
						PlayerWaftOffendSmellBodyodorWriteMsg(mysmellbodyodorent, player);
						return 1;
				}
			} else {
				if (time > (player.nextwaft_smell_bodyodor_time+120)) {
					player.nextwaft_smell_bodyodor_ent = mysmellbodyodorent;
					player.nextwaft_smell_bodyodor_amnt = mysmellbodyodorent.smell_bodyodor;
					player.nextwaft_smell_bodyodor_time = time;
					
					PlayerWaftOffendSmellBodyodorWriteMsg(mysmellbodyodorent, player);
					return 1;
				}
			}
		} else {
			player.nextwaft_smell_bodyodor_ent = mysmellbodyodorent;
			player.nextwaft_smell_bodyodor_amnt = mysmellbodyodorent.smell_bodyodor;
			player.nextwaft_smell_bodyodor_time = time;
					
			PlayerWaftOffendSmellBodyodorWriteMsg(mysmellbodyodorent, player);
			return 1;
		}
	  }
	}
	
	return 0;
}



float PlayerWaftDelightRoses (entity player)
{
	local entity mysmellrosesent;
	mysmellrosesent = world;

	mysmellrosesent = PlayerWaftDetermine(player, 512, 128, smell_roses);
	if (mysmellrosesent) {
	  if (mysmellrosesent != world) {
		if (player.nextwaft_smell_roses_ent) {
			if (player.nextwaft_smell_roses_ent != mysmellrosesent) {
				if (mysmellrosesent.smell_roses > player.nextwaft_smell_roses_amnt)
				{
					if (time > (player.nextwaft_smell_roses_time+60)) {
						player.nextwaft_smell_roses_ent = mysmellrosesent;
						player.nextwaft_smell_roses_amnt = mysmellrosesent.smell_roses;
						player.nextwaft_smell_roses_time = time;
					
						PlayerWaftDelightSmellRosesWriteMsg(mysmellrosesent, player);
						return 1;
					}
				} else if (time > (player.nextwaft_smell_roses_time+320)) {
						player.nextwaft_smell_roses_ent = mysmellrosesent;
						player.nextwaft_smell_roses_amnt = mysmellrosesent.smell_roses;
						player.nextwaft_smell_roses_time = time;
					
						PlayerWaftDelightSmellRosesWriteMsg(mysmellrosesent, player);
						return 1;
				}
			} else {
				if (time > (player.nextwaft_smell_roses_time+240)) {
					player.nextwaft_smell_roses_ent = mysmellrosesent;
					player.nextwaft_smell_roses_amnt = mysmellrosesent.smell_roses;
					player.nextwaft_smell_roses_time = time;
					
					PlayerWaftDelightSmellRosesWriteMsg(mysmellrosesent, player);
					return 1;
				}
			}
		} else {
			player.nextwaft_smell_roses_ent = mysmellrosesent;
			player.nextwaft_smell_roses_amnt = mysmellrosesent.smell_roses;
			player.nextwaft_smell_roses_time = time;
					
			PlayerWaftDelightSmellRosesWriteMsg(mysmellrosesent, player);
			return 1;
		}
	  }
	}
	
	return 0;
}


void PlayerWaft (entity player)
{
	if not (PlayerWaftOffendFaeces (player)) {
		if not (PlayerWaftOffendRottingflesh (player)) {
			if not (PlayerWaftOffendBodyodor (player)) {
				PlayerWaftDelightRoses(player);
			}
		}
	}
}


