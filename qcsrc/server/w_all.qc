// ONLY EVER ADD NEW WEAPONS AT THE END. IF YOU REMOVE ONE, PUT THE LAST ONE ON
// ITS PLACE. THIS IS TO AVOID UNNECESSARY RENUMBERING OF WEAPON IMPULSES.
// IF YOU DISREGARD THIS NOTICE, I'LL KILL YOU WITH THE @!#%'N TUBA
// Warhammerspiked == 24th wep, all others in other wepset
// Everytime we go past +24 weapons we need to add another wepset (24,48,72,etc)
// This can be done by editing the macros (also be wary of the stats code (accuracy etc)
#include "w_laser.qc"
#include "w_shotgun.qc"
#include "w_uzi.qc"
#include "w_grenadelauncher.qc"
#include "w_minelayer.qc"
#include "w_electro.qc"
#include "w_crylink.qc"
#include "w_nex.qc"
#include "w_hagar.qc"
#include "w_rocketlauncher.qc"
#include "w_porto.qc"
#include "w_minstanex.qc"
#include "w_hook.qc"
#include "w_hlac.qc"
#include "w_tuba.qc"
#include "w_rifle.qc"
#include "w_fireball.qc"
#include "w_seeker.qc"
#include "w_pistol.qc"
#include "w_hmg.qc"
#include "w_mg.qc"
#include "w_explosivevest.qc"
#include "w_crossbowdtwr.qc"
#include "w_warhammerspiked.qc"
#include "w_shotgunautomat.qc"
#include "w_pumpshotgun.qc"
#include "w_lightninggun.qc"
#include "w_g98.qc"
#include "w_nukelayer.qc"
#include "w_caltrop.qc"
#include "w_torch.qc"
#include "w_revolver.qc"
#include "w_bigpistol.qc"
#include "w_m1921.qc"
#include "w_flashlight.qc"
#include "w_lrr.qc"
#include "w_multitool.qc"
#include "w_shortsword.qc"
#include "w_broadaxe.qc"
#include "w_longsword.qc"
#include "w_rapier.qc"
#include "w_carbine.qc"
#include "w_utilitool.qc"
#include "w_shackles.qc"
#include "w_spear.qc"
#include "w_pdw.qc"
#include "w_lightpistol.qc"
#include "w_morgenstern.qc"
#include "w_katana.qc"
#include "w_odachi.qc"
#include "w_nagamaki.qc"
#include "w_lightsabre.qc"
#include "w_tetsubo.qc"
#include "w_largepistol.qc"
#include "w_lightauto.qc"
#include "w_magnum.qc"
#include "w_crowbar.qc"
#include "w_yari.qc"
#include "w_ak47.qc"
#include "w_rpg7launcher.qc"
#include "w_aks74u.qc"
#include "w_tt33pistol.qc"
#include "w_ffmagnum.qc"
#include "w_m16mini.qc"
#include "w_m16vn.qc"
#include "w_browninghp.qc"
#include "w_longbow.qc"
#include "w_cudgel.qc"
#include "w_crudebow.qc"
#include "w_compositebow.qc"
#include "w_lightcrossbow.qc"
#include "w_flangedmace.qc"
#include "w_warmallet.qc"
#include "w_kiduchi.qc"
#include "w_microuzi.qc"
#include "w_miniuzi.qc"
#include "w_ra4launcher.qc"
#include "w_stoneaxe.qc"
#include "w_shiningstar.qc"
#include "w_poleaxe.qc"
#include "w_yumibow.qc"
#include "w_ironcrow.qc"
#include "w_handcuffs.qc"
#include "w_greyironmallet.qc"
#include "w_ironknife.qc"
#include "w_dagger.qc"
#include "w_spikedclub.qc"
#include "w_sks45.qc"
#include "w_chainsaw.qc"
#include "w_clawhammer.qc"
#include "w_staffflame.qc"
#include "w_staffmagi.qc"
#include "w_bastardsword.qc"
#include "w_scimitar.qc"
#include "w_infantryaxe.qc"
#include "w_elvenaxe.qc"
#include "w_quarterstaff.qc"
#include "w_elvensabre.qc"
#include "w_waraxe.qc"
#include "w_elvenstaff.qc"
#include "w_powersaw.qc"
#include "w_elvenglaive.qc"
#include "w_woodaxe.qc"
#include "w_doublebitaxe.qc"
#include "w_falchion.qc"
#include "w_axe.qc"
#include "w_pickaxe.qc"
#include "w_elvenhammer.qc"
#include "w_crypistol.qc"
#include "w_sportshotgun.qc"
#include "w_spikedflail.qc"
#include "w_shootingstar.qc"
#include "w_fightersword.qc"
#include "w_styeraug.qc"
#include "w_m9pistol.qc"
#include "w_styertmp.qc"
#include "w_crylancer.qc"
#include "w_m82rifle.qc"
#include "w_amr18.qc"
#include "w_spas12.qc"
#include "w_longpistol.qc"
#include "w_m1903.qc"
#include "w_mosin.qc"
#include "w_mauserpistol.qc"
#include "w_machinepistol.qc"
#include "w_hellriegelsmg.qc"
#include "w_webley.qc"
#include "w_webleylong.qc"
#include "w_chauchat.qc"
#include "w_shosho.qc"
#include "w_bar1918.qc"
#include "w_nagant1895.qc"
#include "w_mg0815.qc"
#include "w_lewismg.qc"
#include "w_lightsabreii.qc"
#include "w_lightsabreiv.qc"
#include "w_lightsabrexi.qc"
#include "w_sunbeam.qc"
#include "w_starblast.qc"
#include "w_sunburst.qc"
#include "w_sunbolt.qc"
#include "w_starlase.qc"
#include "w_svd.qc"
#include "w_bat.qc"
#include "w_spikedmace.qc"
#include "w_sai.qc"
#include "w_spectre.qc"
#include "w_armingsword.qc"
#include "w_defendersword.qc"
#include "w_beardedaxe.qc"
#include "w_spikedcudgel.qc"
#include "w_bronzecudgel.qc"
#include "w_tec9.qc"
#include "w_poundersmg.qc"
#include "w_flamethrower.qc"
#include "w_devastator.qc"
#include "w_hagar2.qc"
#include "w_mortar.qc"
#include "w_l85a2.qc"
#include "w_fnscar.qc"
#include "w_g36c.qc"
#include "w_navy1851revolver.qc"
#include "w_colt44revolver.qc"
#include "w_m16a2.qc"
#include "w_pepperboxrevolver.qc"
#include "w_flintlockpistol.qc"
#include "w_musket.qc"
#include "w_henry1860rifle.qc"
#include "w_sharpsrifle.qc"
#include "w_coltlightning.qc"
#include "w_eightgaugeshotgun.qc"
#include "w_eightgaugesawedoff.qc"
#include "w_tengaugedouble.qc"
#include "w_tengaugesawedoff.qc"
#include "w_bowieknife.qc"
#include "w_milflail.qc"
#include "w_arkansastoothpick.qc"
#include "w_battleaxe.qc"
#include "w_kriegshammer.qc"
#include "w_infantrystaff.qc"
#include "w_dadao.qc"
#include "w_skirmishersaxe.qc"
#include "w_bardiche.qc"
#include "w_templaraxe.qc"
#include "w_crusadersword.qc"
#include "w_tanegashima.qc"
#include "w_p90.qc"
#include "w_fivesevenpistol.qc"
#include "w_m93rpistol.qc"
#include "w_t17mmrifle.qc"
#include "w_famas.qc"
#include "w_knife.qc"
#include "w_m1928.qc"
#include "w_m1929.qc"
#include "w_czskorpion.qc"
#include "w_svskorpion.qc"
#include "w_henry1860maresleg.qc"
#include "w_schofieldrevolver.qc"
#include "w_r1856revolver.qc"
#include "w_winchester1873rifle.qc"
#include "w_winchester1897.qc"
#include "w_m1897trenchgun.qc"
#include "w_ithacastakeout.qc"
#include "w_flamberge.qc"
#include "w_streetsweeper.qc"
#include "w_targetpistol.qc"
#include "w_rpd.qc"
#include "w_m249para.qc"
#include "w_pkm.qc"
//Uses based on other weapons to conserve globals starting here
#include "w_shirasaya.qc"
#include "w_zatoichi.qc"
#include "w_claymore.qc"
#include "w_pudao.qc"

