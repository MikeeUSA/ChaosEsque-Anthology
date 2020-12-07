sportstermirror
{
	dpglossintensitymod  4
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

sportsterchrome
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

dgunchrome
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/dgunchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

sportsterglass-solid
{
	qer_editorimage textures/sportsterglass-solid.tga
	cull back
	
	{
		map textures/sportsterglass-solid.tga
		//blendfunc add
		//rgbGen vertex
		tcgen environment
		tcmod scale 4 4
	}	
}

sportsterglass
{
	qer_editorimage textures/sportsterglass.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/sportsterglass.tga
		blendfunc blend
		rgbGen vertex
	}	
}

sportsterglass-front
{
	qer_editorimage textures/sportsterglass-front.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/sportsterglass-front.tga
		blendfunc blend
		rgbGen vertex
	}	
}

sportsterglass-red
{
	qer_editorimage textures/sportsterglass-red.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/sportsterglass-red.tga
		blendfunc blend
		rgbGen vertex
	}	
}

sportsterglass-orange
{
	qer_editorimage textures/sportsterglass-orange.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/sportsterglass-orange.tga
		blendfunc blend
		rgbGen vertex
	}	
}

sportsterglass-lblue
{
	qer_editorimage textures/sportsterglass-lblue.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/sportsterglass-lblue.tga
		blendfunc blend
		rgbGen vertex
	}	
}

cruizerblack
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/cruizerblack.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

cruizerwhite
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/cruizerwhite.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

limopainted
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/limopainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

sportsterlightpainted
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterlightpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

challengerred
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/challengerred.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

sparrowpainted
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sparrowpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

sparrowdark
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sparrowdark.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

fokkerpainted
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/fokkerpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

sopwithpainted
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sopwithpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}


rubber
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/g3-rubber.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

InsigniaBlue
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterlightpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

g4_wood
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/g4_wood.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

models/modelsnukelaynukemine
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/nukelaynukemine.tga
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

textures/nukelaynukemine
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/nukelaynukemine.tga
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

sedanpainted
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sedanpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

minstb
{
	dpglossexponentmod  64
	dpreflectcube env/exomorph/exomorph
 	{
		map models/weapons/okweaponsblack.tga
		rgbgen lightingDiffuse
	}
}

fastcarpainted
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/fastcarpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

Metal_PM004
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

truckpainted
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/truckpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

struckpainted
{
	dpglossintensitymod  1
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/struckpainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

yugopainted
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/yugopainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}


projwaterdroplet
{
	qer_editorimage textures/liquids_water/ruiner_water.jpg
	qer_trans 0.5
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/liquids_water/ruiner_water.jpg
		blendFunc add
		rgbGen identity
	}
}

farmanwings
{
	qer_editorimage textures/farmanwings.tga
	surfaceparm trans
	cull disable
	qer_trans 0.8

	{
		map textures/farmanwings.tga
		blendfunc blend
		rgbGen vertex
	}	
}

ac_texture
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/ac_texture.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

copper
{
	qer_editorimage textures/caethaver2_base/brushedmetal6.tga
	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/caethaver2_base/brushedmetal6.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

spear_wood
{
	{
		map textures/desertfactory_wood/wood04.tga
	}
	{
		map $lightmap
	}
}

faeces
{
	{
		map textures/castlebunker/fecalsolid1.tga
	}
	{
		map $lightmap
	}
}

//wavy fields of grain
textures/farming/barley
{
	qer_editorimage textures/barley
	surfaceparm nomarks
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nonsolid
	cull none
	deformVertexes wave 50.0 sin 2 2 0.25 0.2
	{
		map textures/barley
		alphaFunc GT0
		rgbGen vertex
	}
	{
		map $lightmap
		blendfunc filter
	}
}

//Grapes
textures/farming/grapes
{
	qer_editorimage textures/grapes2
	surfaceparm nomarks
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nonsolid
	cull none
	{
		map textures/grapes2
		alphaFunc GT0
		rgbGen vertex
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/farming/grapevine
{
	qer_editorimage textures/grapevine
	surfaceparm nomarks
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nonsolid
	cull none
	{
		map textures/grapevine
		alphaFunc GT0
		rgbGen vertex
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/farming/grapevine_moving
{
	qer_editorimage textures/grapevine
	surfaceparm nomarks
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nonsolid
	cull none
	deformVertexes wave 50.0 sin 2 2 0.25 0.2
	{
		map textures/grapevine
		alphaFunc GT0
		rgbGen vertex
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/farming/kelp
{
	qer_editorimage textures/desertfactory_shaders/vines01.jpg
	surfaceparm nomarks
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nonsolid
	deformVertexes wave 50.0 sin 2 2 0.25 0.2
	cull none
	{
		map textures/desertfactory_misc/vines01.tga
		alphaFunc GT0
		rgbGen vertex
	}
}

textures/liquids_lava/largetesslava1
{
	qer_editorimage textures/liquids/protolava.jpg
	surfaceparm nonsolid
	surfaceparm lava
	surfaceparm noimpact
	surfaceparm nolightmap
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 512
	cull none
	{
		map textures/liquids/protolava.jpg
		rgbGen identity
		//tcMod turb 0 0.2 0 0.08
		tcMod turb 0 0.05 0 0.02
	}
}

textures/water/largetesspool3d_5e
{
	qer_editorimage textures/liquids_water/water0_qrp2.tga
	qer_trans 0.5
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm water
	Q3map_TessSize 512
	cull none
	q3map_globaltexture
	{
		map textures/liquids_water/water0_qrp2.tga
		//map textures/liquids_water/water0_qrp2.tga
		tcMod scroll 0.07 0.07
		//blendfunc blend
		blendFunc add
		rgbGen vertex
	}
	dp_water 0.1 0.8  3 3  1 1 1  1 1 1  0.125
}

textures/liquids/largetessslime2_water
{
	qer_editorimage textures/liquids/slime2_noglow.jpg
	qer_trans 0.5
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 512
	cull none
	{
		map textures/liquids/slime2_noglow.jpg
		blendFunc add
		rgbGen vertex
	}
}


textures/morphed/gelslime_warp_largetess
{
	qer_editorimage textures/morphed/gelslime.tga
	q3map_lightimage textures/morphed/gelslime_glow.tga
	qer_trans 0.75
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	q3map_surfacelight 280
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 512
	cull none
	{
		map textures/morphed/gelslime.tga
		rgbGen identity
		depthWrite
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc blend
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/liquids_slime/gelslime-purple-notess
{
	qer_editorimage textures/liquids_slime/gelslime-purple.tga
	q3map_lightimage textures/liquids_slime/gelslime-purple.tga
	qer_trans 20
	dpoffsetmapping - 1 match8 107
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	q3map_surfacelight 280
	cull none
	{
		map textures/liquids_slime/gelslime-purple.tga
		rgbGen identity
		depthWrite
		tcmod scale 1.2 0.7
		tcMod scroll 0.06 0.035
		blendfunc blend
	}
	dp_water 0.3 1  2 2  1 0.1 1  1 0.1 1  0.25
	{
		map $lightmap
		blendfunc blend
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/liquids_water/methane-orange-notess
{
	qer_editorimage textures/liquids_slime/gelslime-orange.tga
	q3map_lightimage textures/liquids_slime/gelslime-orange.tga
	qer_trans 20
	dpoffsetmapping - 1 match8 107
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	q3map_surfacelight 280
	cull none
	{
		map textures/liquids_slime/gelslime-orange.tga
		rgbGen identity
		depthWrite
		tcmod scale 1.2 0.7
		tcMod scroll 0.06 0.035
		blendfunc blend
	}
	dp_water 0.3 1  2 2  1 0.6 0.1  1 0.6 0.1  0.25
	{
		map $lightmap
		blendfunc blend
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/desertfactory_misc/white01_trans
{
	qer_editorimage textures/desertfactory_misc/white01.tga
	surfaceparm trans
	{
		map textures/desertfactory_misc/white01.tga
	}
	{
		map $lightmap
	}
}

lightsabreblade
{
	qer_editorimage textures/lightsabreblade.tga
	surfaceparm trans
	cull back
	qer_trans 0.50

	{
		map textures/lightsabreblade.tga
		blendfunc blend
		rgbGen vertex
	}	
}

lightsabrebladered
{
	qer_editorimage textures/lightsabrebladered.tga
	surfaceparm trans
	cull back
	qer_trans 0.75

	{
		map textures/lightsabrebladered.tga
		blendfunc blend
		rgbGen vertex
	}	
}

lightsabrebladegreen
{
	qer_editorimage textures/lightsabrebladegreen.tga
	surfaceparm trans
	cull back
	qer_trans 0.75

	{
		map textures/lightsabrebladegreen.tga
		blendfunc blend
		rgbGen vertex
	}	
}

lightsabrebladeblue
{
	qer_editorimage textures/lightsabrebladeblue.tga
	surfaceparm trans
	cull back
	qer_trans 0.75

	{
		map textures/lightsabrebladeblue.tga
		blendfunc blend
		rgbGen vertex
	}	
}

gun.paint.metal
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}
}

de-gunmetal
{
	cull none
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}
}

de-gunmetal-slide
{
	cull none
	{
		map textures/de_slidemetal.tga
	}
	{
		map $lightmap
	}
}

de-plastic
{
	{
		map textures/de-plastic.tga
	}
	{
		map $lightmap
	}
}

magnum-gunmetal
{
	qer_editorimage textures/ex2x/base/base_metalmaterial1.tga
	
	q3map_bounceScale  0.5
	dpoffsetmapping - 0.5 match8 204
	dpglossintensitymod  3
	dpglossexponentmod  4


	{
		map textures/ex2x/base/base_metalmaterial1.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

crowbarblade
{
	qer_editorimage textures/ex2x/base/base_metalmaterial1.tga
	dpglossintensitymod  3
	dpglossexponentmod  4


	{
		map textures/ex2x/base/base_metalmaterial1.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

yari_wood
{
	{
		map textures/castlebunker/wizwood1_2scolor_shirt.tga
	}
	{
		map $lightmap
	}
}

yari_wood_c
{
	{
		map textures/castlebunker/wizwood1_2scolor.tga
	}
	{
		map $lightmap
	}
}

longbowwood
{
	{
		map textures/egyptsoc_mat/wood05b.tga
	}
	{
		map $lightmap
	}
}

longbowgrip
{
	{
		map textures/blender_pubdomain_cloth/denimgray_tile.tga
	}
	{
		map $lightmap
	}
}

longbowstring
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}

cudgelwood
{
	{
		map textures/egyptsoc_mat/wood04.tga
	}
	{
		map $lightmap
	}
}

textures/desertfactory_wood/wood04_notjunc
{
	qer_editorimage textures/desertfactory_wood/wood04.tga
	q3map_notjunc
	{
		map textures/desertfactory_wood/wood04.tga
	}
	{
		map $lightmap
	}
}

crudebowwood
{
	{
		map textures/egyptsoc_mat/wood18.tga
	}
	{
		map $lightmap
	}
}

crudebowgrip
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}

crudebowstring
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}


compositebowwood
{
	{
		map textures/egyptsoc_mat/wood09.tga
	}
	{
		map $lightmap
	}
}

compositebowwoodf
{
	{
		map textures/egyptsoc_mat/wood17.tga
	}
	{
		map $lightmap
	}
}

compositebowhorn
{
	{
		map textures/egyptsoc_mat/wood02.tga
	}
	{
		map $lightmap
	}
}

compositebowgrip
{
	{
		map textures/blender_pubdomain_cloth/denimgray_tile.tga
	}
	{
		map $lightmap
	}
}

compositebowgrip2
{
	{
		map textures/blender_pubdomain_cloth/denimwhite_tile.tga
	}
	{
		map $lightmap
	}
}

compositebowstring
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}


lightcrossbowlimbs
{
	{
		map textures/egyptsoc_mat/wood18.tga
	}
	{
		map $lightmap
	}
}

lightcrossbow
{
	{
		map textures/egyptsoc_mat/wood04.tga
	}
	{
		map $lightmap
	}
}

lightcrossbowmetal
{
	{
		map textures/crossbowdtwr.tga
	}
	{
		map $lightmap
	}
}

lightcrossbowgrip
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}

lightcrossbowstring
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}


flangedmacmetal
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}
}

flangedmacehandle
{
	{
		map textures/leatherblack.tga
	}
	{
		map $lightmap
	}
}

flangedmacehandle2
{
	{
		map textures/leatherwhite.tga
	}
	{
		map $lightmap
	}
}

wmalletmetal
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}
}

wmalletwood
{
	{
		map textures/rpkwood.tga
	}
	{
		map $lightmap
	}
}

kiduchi
{
	{
		map textures/lightwood.tga
	}
	{
		map $lightmap
	}
}

textures/oilocean
{
	qer_editorimage textures/caethaver2_deco/cat2-oil.tga
	surfaceparm nonsolid
	surfaceparm water
	//deformVertexes wave 150.0 sin 2 5 0.25 0.1
	//Q3map_TessSize 512
	cull none
	q3map_globaltexture
	{
		map textures/caethaver2_deco/cat2-oil.tga
		blendfunc filter
		tcMod turb 0 0.1 0.25 0.05
		tcMod strech 0 1 0.5 0.025
	}
	dp_water 0.8 1.0  3 3  1 1 1  1 1 1  0.1
}

////////////////////////////////////////
//Materials used for sweethome3d items//
////////////////////////////////////////
mattblack
{
	{
		map textures/mac10-black.tga
	}
	{
		map $lightmap
	}
}

metallic
{
	{
		map textures/mac10-gunmetalgrey.tga
	}
	{
		map $lightmap
	}
}


offwhite
{
	{
		map textures/phillipk2x/base/pk02_generic01a.tga
	}
	{
		map $lightmap
	}
}

darkgreymetal
{
	{
		map textures/phillipk2x/base/pk02_generic01b.tga
	}
	{
		map $lightmap
	}
}

transparentblack
{
	{
		map textures/caethaver2_deco/glasspane2.tga
	}
	{
		map $lightmap
	}	
}

panel
{
	{
		map textures/caethaver2_base/brushedmetal2.tga
	}
	{
		map $lightmap
	}
}

dullmetal
{
	{
		map textures/mac10-gunmetalmedgrey.tga
	}
	{
		map $lightmap
	}
}

shinyblack
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}
}

Aluminum
{
	{
		map textures/caethaver2_base/brushedmetal1.tga
	}
	{
		map $lightmap
	}
}

aluminium
{
	{
		map textures/caethaver2_base/brushedmetal1.tga
	}
	{
		map $lightmap
	}
}

////This is for stove2
Line15_1
{
	{
		map textures/caethaver2_base/brushedmetal3.tga
	}
	{
		map $lightmap
	}
}

Box11_3
{
	{
		map textures/caethaver2_base/brushedmetal1.tga
	}
	{
		map $lightmap
	}
}

//Red, so using team colours so you can change it
Line0911_5
{
	{
		map textures/brushedmetalsp.tga
	}
	{
		map $lightmap
	}
}

ChamferBox01_6
{
	{
		map textures/caethaver2_base/brushedmetal2.tga
	}
	{
		map $lightmap
	}
}

//Black
Box13_8
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}
}

Box12_10
{
	{
		map textures/caethaver2_deco/glasspane2.tga
	}
	{
		map $lightmap
	}	
}

//This is a red thing
ChamferCyl04_14
{
	{
		map textures/caethaver2_base/crinkledmetal1.tga
	}
	{
		map $lightmap
	}
}

Rectangle02_16
{
	{
		map textures/mac10-gunmetalmedgrey.tga
	}
	{
		map $lightmap
	}
}

Line22_20
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

Rectangle07_55
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}
}

potionglasscube
{
	//Very transparent, slight violet tinge in some spots due to gloneminussrccolor etc
	qer_editorimage textures/castlebunker/colddarksky_night_rt.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/colddarksky_night_rt.tga
		blendfunc GL_ONE_MINUS_SRC_COLOR GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglasscube0
{
	//Very transparent, slight violet tinge in some spots due to gloneminussrccolor etc
	qer_editorimage textures/castlebunker/colddarksky_night_ft.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/colddarksky_night_ft.tga
		blendfunc GL_ONE_MINUS_SRC_COLOR GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglasscube1
{
	//Very transparent, slight green tinge
	qer_editorimage textures/castlebunker/colddarksky_night_ft.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/colddarksky_night_ft.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglasscube2
{
	//Very transparent, more shiny
	qer_editorimage textures/castlebunker/colddarksky_night_rt.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/colddarksky_night_rt.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglasselec
{
	//Very transparent, white electricy
	qer_editorimage gfx/menu/illuminos/background.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map gfx/menu/illuminos/background.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}


potionglasssmokey
{
	//Very transparent, more smokey
	qer_editorimage textures/castlebunker/colddarksky_night_up.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/colddarksky_night_up.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglasssmokey0
{
	//White, translucent
	qer_editorimage textures/castlebunker/industrial_exterior2.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/industrial_exterior2.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglassshiny
{
	//Shiny
	qer_editorimage textures/castlebunker/spirecontrol_dusk_rt.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/spirecontrol_dusk_rt.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglassmystic
{
	//Mystic
	qer_editorimage textures/castlebunker/meddarksky_rt.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/meddarksky_rt.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglassmystic0
{
	//Mysticish
	qer_editorimage textures/castlebunker/tanandgreen_dusk_ft.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/tanandgreen_dusk_ft.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglassverymystic
{
	//Very Mystic
	qer_editorimage env/extragalactic/nebulae_bk.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map env/extragalactic/nebulae_bk.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}


potionglassgreenred
{
	//Green and red
	qer_editorimage textures/castlebunker/frankishtowersky_dusk_lf.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/frankishtowersky_dusk_lf.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglassgreenred0
{
	//red, green
	qer_editorimage textures/castlebunker/happyhills_dusk_rt.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/happyhills_dusk_rt.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglasspurple
{
	//Purpleish
	qer_editorimage textures/castlebunker/kstbunkersky_dusk_ft.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/kstbunkersky_dusk_ft.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglasspurple0
{
	//Purpleish, transparent
	qer_editorimage textures/castlebunker/opposingcastles_dusk_bk.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/opposingcastles_dusk_bk.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglassorange
{
	//Orangeish
	qer_editorimage textures/castlebunker/orangecloudsky_dusk_rt.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/castlebunker/orangecloudsky_dusk_rt.tga
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

potionglassyellow
{
	//yellowish, brightish
	qer_editorimage env/distant_sunset/distant_sunset_rt.jpg
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map env/distant_sunset/distant_sunset_rt.jpg
		blendfunc GL_ONE GL_ONE
		//rgbGen vertex
		tcgen environment
		//tcmod scale 4 4
	}
	/*{
		map $lightmap
		rgbGen identity
		tcgen lightmap
	}*/
}

//For now so we don't have to make the normals correct...
Defender
{
	cull none
	{
		map textures/Defender.tga
	}
	{
		map $lightmap
	}
}

nexuizstatueDS
{
	cull none
	{
		map textures/nexuizstatue.tga
	}
	{
		map $lightmap
	}
}

troll-cloth
{
	cull none
	{
		map textures/troll-cloth.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

wyvern_diffuseDS
{
	cull none
	{
		map textures/wyvern_diffuse.tga
	}
	{
		map $lightmap
	}
}

wyvern_diffuse_waterDS
{
	cull none
	{
		map textures/wyvern_diffuse_water.tga
	}
	{
		map $lightmap
	}
}

wyvern_diffuse_airDS
{
	cull none
	{
		map textures/wyvern_diffuse_air.tga
	}
	{
		map $lightmap
	}
}

wyvern_diffuse_fireDS
{
	cull none
	{
		map textures/wyvern_diffuse_fire.tga
	}
	{
		map $lightmap
	}
}

armorknightDS
{
	cull none
	{
		map textures/armorknight.tga
	}
	{
		map $lightmap
	}
}

armorknightblackDS
{
	cull none
	{
		map textures/armorknightblack.tga
	}
	{
		map $lightmap
	}
}

armorknightwhiteDS
{
	cull none
	{
		map textures/armorknightwhite.tga
	}
	{
		map $lightmap
	}
}

shiningstarmetal
{
	dpglossintensitymod  4
	dpglossexponentmod  8
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

shiningstarh1
{
	{
		map textures/leatherwhite2.tga
	}
	{
		map $lightmap
	}
}

shiningstarh2
{
	{
		map textures/leatherwhite.tga
	}
	{
		map $lightmap
	}
}

yumibowwood
{
	{
		map textures/yumibowwood.tga
	}
	{
		map $lightmap
	}
}

yumibowgrip
{
	{
		map textures/blender_pubdomain_cloth/denimgray_tile.tga
	}
	{
		map $lightmap
	}
}

yumibowgrip2
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}

yumibowstring
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}

handcuffchrome
{
	//dpglossintensitymod  2
	//dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/handcuffchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

brass
{
	qer_editorimage textures/caethaver2_base/brushedmetal4.tga
	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/caethaver2_base/brushedmetal4.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

clawhammermetal
{
	qer_editorimage textures/mac10-gunmetalmedgrey.tga
	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/mac10-gunmetalmedgrey.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

chaisefabric
{
	qer_editorimage models/chairs/chair02_texture.tga
	{
		map models/chairs/chair02_texture.tga
	}
	{
		map $lightmap
	}
}

workbenchsaw
{
	qer_editorimage textures/workbenchsaw.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/workbenchsaw.tga
		blendfunc blend
		rgbGen vertex
	}	
}

workbenchmetal
{
	qer_editorimage textures/mac10-gunmetalmedgrey.tga

	{
		map textures/mac10-gunmetalmedgrey.tga
		

	}
	{
		map $lightmap
	}
}

workbenchrope
{
	{
		map textures/blender_pubdomain_cloth/denimtan_tile.tga
	}
	{
		map $lightmap
	}
}

forgeWroughtIron
{
	{
		map textures/morgenstern_head.tga
	}
	{
		map $lightmap
	}
}

forgeLogEdgeWeathered
{
	{
		map textures/jcr_high/barkch.tga
	}
	{
		map $lightmap
	}
}

forgeOakBark
{
	{
		map textures/jcr_high/barkdk.tga
	}
	{
		map $lightmap
	}
}

forgeBrownLeather
{
	{
		map textures/leatherdarkbrown.tga
	}
	{
		map $lightmap
	}
}

forgeWood
{
	{
		map textures/evil1_woods/wood_pnl_drty.tga
	}
	{
		map $lightmap
	}
}

forgeGreyBrick
{
	{
		map textures/e7/e7brickfloor01.tga
	}
	{
		map $lightmap
	}
}

forgeStone
{
	{
		map textures/nexuizstatue.tga
	}
	{
		map $lightmap
	}
}

forgeCoal
{
	{
		map textures/0ad_special/burningrock.tga
	}
	//No light map, glows
}

forgeSandstone
{
	{
		map textures/egyptsoc_mat/sand1a.tga
	}
	{
		map $lightmap
	}
}

bullionbar
{
	//Colormapped
	{
		map textures/brushedmetalsppa.tga
	}
	{
		map $lightmap
	}
}

bullionbar_tin
{
	{
		map textures/caethaver2_deco/foil5.tga
	}
	{
		map $lightmap
	}
}

bullionbar_iron
{
	{
		map textures/morgenstern_head.tga
	}
	{
		map $lightmap
	}
}

bullionbar_bronze
{
	{
		map textures/caethaver2_base/brushedmetal4.tga
	}
	{
		map $lightmap
	}
}

bullionbar_copper
{
	{
		map textures/caethaver2_deco/foil3.tga
		//map textures/caethaver2_base/brushedmetal9.tga
		tcgen environment
	}
	{
		map $lightmap
	}
}

bullionbar_silver
{
	{
		map textures/caethaver2_base/brushedmetal1.tga
		tcgen environment
	}
	{
		map $lightmap
	}
}

bullionbar_gold
{
	{
		map textures/caethaver2_deco/foil2.tga
		//map textures/caethaver2_base/brushedmetal8.tga
		tcgen environment
	}
	{
		map $lightmap
	}
}

bullionbar_plat
{
	{
		map textures/caethaver2_deco/foil4.tga
		tcgen environment
	}
	{
		map $lightmap
	}
}

bullionbar_jade
{
	{
		map textures/coin_jade.tga
		tcgen environment
	}
	{
		map $lightmap
	}
}

bullionbar_amber
{
	{
		map textures/coin_amber.tga
		tcgen environment
	}
	{
		map $lightmap
	}
}

bullionbar_steel
{
	{
		map textures/caethaver2_base/brushedmetal2.tga
	}
	{
		map $lightmap
	}
}

bullionbar_uranium
{
	{
		map textures/caethaver2_base/brushedmetal3.tga
	}
	{
		map $lightmap
	}
}

bullionbar_other
{
	//Placeholder really
	{
		map textures/gemcolormap.tga
	}
	{
		map $lightmap
	}
}

staffflame
{
	{
		map textures/desertfactory_wood/wood03.tga
	}
	{
		map $lightmap
	}
}
staffmagi
{
	{
		map textures/egyptsoc_mat/wood02.tga
	}
	{
		map $lightmap
	}
}
staffflamecrystal
{
	qer_editorimage textures/gemrb1.tga
	surfaceparm trans
	cull none
	qer_trans 0.70

	{
		map textures/gemrb1.tga
		blendfunc blend
		rgbGen vertex
	}
}
staffmagicrystal
{
	qer_editorimage textures/gemam1.tga
	surfaceparm trans
	cull none
	qer_trans 0.70

	{
		map textures/gemam1.tga
		blendfunc blend
		rgbGen vertex
	}	
}

bastardswordhilt
{
	{
		map textures/mac10-gunmetalgrey.tga
	}
	{
		map $lightmap
	}
}

cylinderexpfire
{
	//surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes wave 50.0 sin 2 2 0.25 0.2
	cull disable
	{
		map models/sphere/sphexp.tga
		//map textures/0ad_special/flamingrock.tga
		tcmod page 4 4 0.05
	}
	{
		map $lightmap
		//rgbGen identity
		//tcGen lightmap
		//blendfunc filter
	}	
}

scimitarbrass
{
	qer_editorimage textures/caethaver2_base/brushedmetal4.tga
	
	q3map_bounceScale 0.5
	dpoffsetmapping - 1
	dpglossintensitymod  1
	dpglossexponentmod  2

	{
		map textures/caethaver2_base/brushedmetal4.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}


elvencapmetal
{	dpglossintensitymod  1.5
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	//Colormapped
	{
		map textures/brushedmetalsppa.tga
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

infantryaxemetal
{
	dpglossintensitymod  1.5
	dpglossexponentmod  2
	dpreflectcube env/exomorph/exomorph
	{
		map textures/caethaver2_base/brushedmetal1.tga
	}
	{
		map $lightmap
		//rgbGen identity
		//tcGen lightmap
		blendfunc filter
	}
}


elvenaxewood
{
	{
		map textures/egyptsoc_mat/wood07.tga
	}
	{
		map $lightmap
	}
}

//powersaw
//powersawbladecenter
//powersawbladeedge
//powersawdrive
//powersawblack
//powersawskin
//powersawlabel

powersawlabel
{
	{
		map textures/desertfactory_signs/shock_dirty.tga
	}
	{
		map $lightmap
	}
}

powersawblack
{
	{
		map textures/mac10-flat.tga 
	}
	{
		map $lightmap
	}
}

powersawskin
{
	{
		map textures/powersawcolor.tga
	}
	{
		map $lightmap
	}
}


powersawbladecenter
{
	dpglossintensitymod  2.5
	dpglossexponentmod  2.5
	dpreflectcube env/exomorph/exomorph
	{
		map textures/caethaver2_base/brushedmetal1.tga
	}
	{
		map $lightmap
		//rgbGen identity
		//tcGen lightmap
		blendfunc filter
	}
}

powersawbladeedge
{
	dpglossintensitymod  2.5
	dpglossexponentmod  2.5
	dpreflectcube env/exomorph/exomorph
	{
		map textures/caethaver2_base/brushedmetal6.tga
	}
	{
		map $lightmap
		//rgbGen identity
		//tcGen lightmap
		blendfunc filter
	}
}

powersawdrive
{
	dpglossintensitymod  0.5
	dpglossexponentmod  0.5
	dpreflectcube env/exomorph/exomorph
	{
		map textures/caethaver2_base/brushedmetal3.tga
	}
	{
		map $lightmap
		//rgbGen identity
		//tcGen lightmap
		blendfunc filter
	}
}

bulldozerpaint
{
	{
		map textures/bulldozerpainttex.tga
	}
	{
		map $lightmap
	}
}

bulldozerblack
{
	{
		map textures/caethaver2_base/brushedmetal3.tga
	}
	{
		map $lightmap
	}
}

bulldozerrebarbig
{
	{
		map textures/evil3_support/mtlsupport_pipes.tga
	}
	{
		map $lightmap
	}
}

bulldozersteel
{
	{
		map textures/caethaver2_base/brushedmetal1.tga
	}
	{
		map $lightmap
	}
}


bulldozertread
{
	{
		map textures/evil3_metals/mtldrk1.tga
	}
	{
		map $lightmap
	}
}

tools_gnarly_wood
{
	{
		map textures/gnarlytools.tga
	}
	{
		map $lightmap
	}
}

tools_gnarly_head
{
	dpglossintensitymod  1.25
	dpglossexponentmod  1.25
	{
		map textures/gnarlytools.tga
	}
	{
		map $lightmap
	}
}


falchionbrass
{
	qer_editorimage textures/caethaver2_base/brushedmetal4.tga
	
	q3map_bounceScale 0.5
	dpoffsetmapping - 1
	dpglossintensitymod  1.2
	dpglossexponentmod  1.8

	{
		map textures/caethaver2_base/brushedmetal4.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

falchionwood
{
	{
		map textures/e7/e7panelwood.tga
	}
	{
		map $lightmap
	}
}

fighterswordedge
{
	dpglossintensitymod  0.4
	dpglossexponentmod  0.4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/sportsterchrome.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

fighterswordgrip
{
	{
		map textures/berzerker_texture.tga
	}
	{
		map $lightmap
	}
}

fighterswordguard
{
	{
		map textures/berzerker_texture.tga
	}
	{
		map $lightmap
	}
}

fighterswordmetal
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/berzerker_texture.tga
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

styeraugglass
{
	qer_editorimage textures/styeraugglass.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/styeraugglass.tga
		blendfunc blend
		rgbGen vertex
	}	
}

styeraugmag
{
	qer_editorimage textures/styeraugmag.tga
	surfaceparm trans
	cull back
	qer_trans 0.85

	{
		map textures/styeraugmag.tga
		blendfunc blend
		rgbGen vertex
	}	
}


m9pistoltex
{
	qer_editorimage textures/m9pistoltex.tga
	cull disable

	{
		map textures/m9pistoltex.tga
	}
	{
		map $lightmap
	}	
}

crylancerfire
{
	surfaceparm trans
	surfaceparm noimpact
	surfaceparm nolightmap
	deformVertexes wave 2 sin 0 0.2 0.25 10.2
	Q3map_TessSize 128
	cull disable
	{
		map textures/crylancerfire.tga
		//blendFunc add
		//rgbGen identity
		blendfunc blend
		tcgen environment
		tcmod scale 4 4
	}
}
//3.3.1 deformVertexes wave <div> <func> <base> <amplitude> <phase> <freq>
//Designed for water surfaces, modifying the values differently at each point. //It accepts the standard wave functions of the type sin, triangle, square, //sawtooth or inversesawtooth. The "div" parameter is used to control the wave //"spread" - a value equal to the tessSize of the surface is a good default //value (tessSize is subdivision size, in game units, used for the shader when //seen in the game world) .


tanka7vcamo
{
	qer_editorimage textures/tankarmordesat.tga

	{
		map textures/tankarmordesat.tga
	}
	{
		map $lightmap
	}	
}


tanka7vhull
{
	qer_editorimage textures/tankarmorgrey.tga

	{
		map textures/tankarmorgrey.tga
	}
	{
		map $lightmap
	}	
}

tanka7vinside
{
	qer_editorimage textures/tankarmorgrey.tga

	{
		map textures/tankarmorgrey.tga
	}
	{
		map $lightmap
	}	
}

m1903wood
{
	{
		map textures/workbenchwood3.tga
	}
	{
		map $lightmap
	}	
}

m1903metal
{
	{
		map textures/exx/base/base_metal02.tga
	}
	{
		map $lightmap
	}	
}


mosinwood
{
	{
		map textures/torch_wood.tga
	}
	{
		map $lightmap
	}	
}

mosinmetal
{
	{
		map textures/exx/base/base_metal03.tga
	}
	{
		map $lightmap
	}	
}



chauchatmetal1
{
	{
		map textures/exx/base/base_metal01.tga
	}
	{
		map $lightmap
	}	
}

chauchatmetal2
{
	{
		map textures/exx/base/base_metal07rust.tga
	}
	{
		map $lightmap
	}	
}

chauchatmetal3
{
	{
		map textures/exx/base/base_metal02.tga
	}
	{
		map $lightmap
	}	
}

chauchatmetal4
{
	{
		map textures/exx/base/base_metal06rust.tga
	}
	{
		map $lightmap
	}	
}

chauchatmetalgrip
{
	{
		map textures/exx/floor/floor_clang01b.tga
	}
	{
		map $lightmap
	}	
}


chauchatwood
{
	{
		map textures/egyptsoc_mat/wood09.tga
	}
	{
		map $lightmap
	}	
}



shoshometal1
{
	{
		map textures/exx/base/base_metal03.tga
	}
	{
		map $lightmap
	}	
}

shoshometal2
{
	{
		map textures/exx/base/base_metal05rust.tga
	}
	{
		map $lightmap
	}	
}

shoshometal3
{
	{
		map textures/exx/base/base_metal02.tga
	}
	{
		map $lightmap
	}	
}

shoshometal4
{
	{
		map textures/exx/base/base_metal01.tga
	}
	{
		map $lightmap
	}	
}

shoshometalgrip
{
	{
		map textures/exx/floor/floor_clang01.tga
	}
	{
		map $lightmap
	}	
}


shoshowood
{
	{
		map textures/egyptsoc_mat/wood18.tga
	}
	{
		map $lightmap
	}	
}

bar1918metal1
{
	{
		map textures/mac10-gunmetalmedgrey.tga
	}
	{
		map $lightmap
	}	
}

bar1918metal2
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}	
}

bar1918metal3
{
	{
		map textures/mac10-gunmetalgrey.tga
	}
	{
		map $lightmap
	}	
}


bar1918wood
{
	{
		map textures/egyptsoc_mat/wood05a.tga
	}
	{
		map $lightmap
	}	
}



nagantbrass
{
	qer_editorimage textures/caethaver2_base/brushedmetal4.tga
	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/caethaver2_base/brushedmetal4.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}	
}

nagantmetal2
{
	{
		map textures/mac10-gunmetalgrey.tga
	}
	{
		map $lightmap
	}	
}


nagantmetal1
{
	{
		map textures/mac10-gunmetal.tga
	}
	{
		map $lightmap
	}	
}



nagantwood
{
	{
		map textures/rpkwood.tga
	}
	{
		map $lightmap
	}	
}

mg0815wood
{
	{
		map textures/egyptsoc_mat/wood07.tga
	}
	{
		map $lightmap
	}	
}


lewismglightmetal
{
	qer_editorimage textures/ex2x/base/base_metalmaterial1.tga
	
	q3map_bounceScale  0.5
	dpoffsetmapping - 0.5 match8 204
	dpglossintensitymod  3
	dpglossexponentmod  4


	{
		map textures/ex2x/base/base_metalmaterial1.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

lewismgaluminum
{
	{
		map textures/ex2x/base/base_metalmaterial1.tga
	}
	{
		map $lightmap
	}	
}

lewismgwood
{
	{
		map textures/a300wood.tga
	}
	{
		map $lightmap
	}	
}

billowingsmokenade
{
	surfaceparm nonsolid
	surfaceparm noimpact
	//surfaceparm nolightmap
	cull none
	deformVertexes wave 50.0 sin 2 2 0.25 0.2
	cull none
	{
		map textures/sphexp3
		//map textures/billowingsmokenade
	}
	{
		map $lightmap
		blendfunc filter
		tcMod turb 0 0.05 0 0.02
		tcMod rotate 10
		tcMod scroll 0.05 0.1
	}
}

horndemon
{
	{
		map textures/horndemon.jpg
	}
	{
		map $lightmap
	}	
}

starbur_projectile_core
{
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite
	{
		map textures/projectiles/starbur_projectile_core.tga
		blendfunc GL_SRC_ALPHA GL_ONE
		rgbGen lightingDiffuse
	}
}
starbur_projectile_long
{
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite2
	{
		map textures/projectiles/starbur_projectile_long.tga
		blendfunc GL_SRC_ALPHA GL_ONE
		rgbGen lightingDiffuse
	}
}

sbeamweplight
{
	cull none
	{
		//map textures/nexgun
		map textures/phillipk2x/base/pk02_generic01a.tga
		//textures/sopwithwhite.tga
	}
	{
		map $lightmap
	}	
}

sbeamwepdark
{
	cull none
	{
		map textures/mac10-black
		//map textures/phillipk2x/base/pk02_generic01a.tga

	}
	{
		map $lightmap
	}	
}

sbweplasercolor
{
	cull none
	{
		map textures/potionyellow
	}
	{
		map $lightmap
	}	
}

magiccircle4a
{
	cull none
	{
		map models/circles/magiccircle4a.tga
		blendfunc blend
	}	
}

magiccircle4smalldesat
{
	cull none
	{
		map models/circles/magiccircle4smalldesat.tga
		blendfunc blend
	}	
}

magiccircle5a
{
	cull none
	{
		map models/circles/magiccircle5a.tga
		blendfunc blend
	}	
}

armingswordblade
{
	qer_editorimage textures/caethaver2_base/brushedmetal1.tga
	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/caethaver2_base/brushedmetal1.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}	
}

armingswordhilt
{
	{
		map textures/caethaver2_base/brushedmetal2.tga
	}
	{
		map $lightmap
	}	
}


bronzecudgel
{	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/caethaver2_base/brushedmetal4.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

bronzecudgel2
{	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/caethaver2_base/brushedmetal3.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

bronzecudgel3
{	
	q3map_bounceScale 0.5
	dpoffsetmapping - 2
	dpglossintensitymod  3
	dpglossexponentmod  4

	{
		map textures/caethaver2_base/brushedmetal6.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}


colt44chrome
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/colt44chrome.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


pepperboxrevolver
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/pepperboxrevolver.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}





musketleather
{
	{
		map textures/leatherdarkbrown.tga
	}
	{
		map $lightmap
	}
}

musketbrass
{
	{
		map textures/caethaver2_base/brushedmetal4.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

musketbronze
{
	{
		map textures/caethaver2_base/brushedmetal3.tga
		

	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

musketmetallight
{
	{
		map textures/caethaver2_base/brushedmetal1.tga
		tcgen environment
	}
	{
		map $lightmap
	}
}

musketmetaldark
{
	{
		map textures/mac10-gunmetalgrey.tga
	}
	{
		map $lightmap
	}
}

musketflint
{
	{
		map textures/morgenstern_head.tga
	}
	{
		map $lightmap
	}
}

musketmetalbarrel
{
	////dpglossintensitymod  1.24
	////dpglossexponentmod  2.24
	//dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/musketchrome.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


musketwood
{
	{
		map textures/desertfactory_wood/wood02.tga
	}
	{
		map $lightmap
	}
}



henryriflebrass
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/henryriflebrass.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


sharpsriflewood
{
	{
		map textures/egyptsoc_mat/wood02.tga
	}
	{
		map $lightmap
	}	
}


sharpsriflemetal
{
	{
		map textures/mac10-gunmetalmedgrey.tga
	}
	{
		map $lightmap
	}	
}


sharpsrifleglass
{
	qer_editorimage textures/caethaver2_deco/glasspane10.tga
	surfaceparm trans
	cull disable
	qer_trans 0.50

	{
		map textures/caethaver2_deco/glasspane10_2.tga
		blendfunc add
		//rgbGen vertex
		tcgen environment
		tcmod scale 4 4
	}
}

coltlightningchrome
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/coltlightningchrome.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

eightgaugemetal
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/eightgaugemetal.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

eightgaugemetal2
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/eightgaugemetal2.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

sawedoffwood
{
	{
		map textures/savdm6ish/wizwood1_2.tga
	}
	{
		map $lightmap
	}
}


tengaugemetal
{
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tengaugemetal.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

tengaugemetalblade
{
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tengaugemetal.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

tengaugemetal2
{
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tengaugemetal2.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


tengaugemetal3
{
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tengaugemetal3.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


tengaugemetalblade3
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tengaugemetal3.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

tengaugemetal5
{
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tengaugemetal5.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


glassbulletholedecal1
{
	qer_editorimage textures/caethaver2_decal/gbullethit1.tga
	surfaceparm trans
	//cull none
	qer_trans 0.50

	{
		map textures/caethaver2_decal/gbullethit1.tga
		//blendfunc blend
		blendfunc add
		rgbGen vertex
	}	
}


scofieldtex
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/schofieldtex.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


winchester1873tex
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/winchester1873tex.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}



colt44chrome2
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/colt44chrome2.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

colt44chrome2a
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/heaven/heaven_
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/colt44chrome2.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

colt44chrome2b
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/colt44chrome2.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


//A clip for models, furniture, to make rough box models of in blender etc
furnishingclip
{
        qer_trans 0.40
        surfaceparm nodraw
        surfaceparm nolightmap
        surfaceparm nonsolid
        surfaceparm trans
        surfaceparm nomarks
        //surfaceparm noimpact
        surfaceparm playerclip
}

//For bounding box even when turned, to inform engine of the bounds
furnishingskip
{
	qer_nocarve
	qer_trans 0.30
	surfaceparm nodraw
        surfaceparm nolightmap
	surfaceparm nonsolid
	surfaceparm skip
	surfaceparm trans
}


retropainted
{
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map textures/retropainted.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

retrored
{
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map textures/retrored.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}


brushedmetalspvecmap
{
	
	{
		map textures/brushedmetalsp.tga
		
		
		tcGen environment
		tcmod scale 1 1
	}
	{
		map $lightmap
	}
}

basickcabinetlight
{
	
	{
		map textures/suburbtex_materials/plastic3.tga		
		
		tcGen environment
		tcmod scale 4 4
	}
	{
		map $lightmap
	}
}


deskdesatchrome
{
	//dpglossintensitymod  1.24
	//dpglossexponentmod  2.24
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/deskdesatchrome.tga 
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}



redrosepetal
{
	qer_editorimage textures/rosepetals/redrosepetal.tga
	surfaceparm trans
	//cull none
	qer_trans 0.90

	{
		map textures/rosepetals/redrosepetal.tga
		blendfunc blend
		//blendfunc add
		rgbGen vertex
	}	
}


pinkrosepetal
{
	qer_editorimage textures/rosepetals/pinkrosepetal.tga
	surfaceparm trans
	//cull none
	qer_trans 0.90

	{
		map textures/rosepetals/pinkrosepetal.tga
		blendfunc blend
		//blendfunc add
		rgbGen vertex
	}	
}


whiterosepetal
{
	qer_editorimage textures/rosepetals/whiterosepetal.tga
	surfaceparm trans
	//cull none
	qer_trans 0.90

	{
		map textures/rosepetals/whiterosepetal.tga
		blendfunc blend
		//blendfunc add
		rgbGen vertex
	}	
}


blackrosepetal
{
	qer_editorimage textures/rosepetals/blackrosepetal.tga
	surfaceparm trans
	//cull none
	qer_trans 0.90

	{
		map textures/rosepetals/blackrosepetal.tga
		blendfunc blend
		//blendfunc add
		rgbGen vertex
	}	
}


blackfeather
{
	qer_editorimage textures/feathers/blackfeather.tga
	surfaceparm trans
	//cull none
	qer_trans 0.90

	{
		map textures/feathers/blackfeather.tga
		blendfunc blend
		//blendfunc add
		rgbGen vertex
	}	
}


whitefeather
{
	qer_editorimage textures/feathers/whitefeather.tga
	surfaceparm trans
	//cull none
	qer_trans 0.90

	{
		map textures/feathers/whitefeather.tga
		blendfunc blend
		//blendfunc add
		rgbGen vertex
	}	
}




cruizerblack2
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map textures/cruizerblack2.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

cruizerblack2a
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/heaven/heaven_
	{
		map textures/cruizerblack2.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

cruizerblack2b
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/cruizerblack2.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}

textures/spirecontrolshaders/terrainIII
{
   qer_editorimage textures/bztourny/arkhart-grass2.png
   q3map_lightmapSampleOffset 8
   q3map_globalTexture
   q3map_nonplanar
   q3map_shadeangle 95
   //q3map_alphaMod dotproduct2scale ( 0 1 0 0.1542 0.6333 ) // Pre q3map2 Fix
   q3map_alphaMod dotproduct2scale ( 0 1 0 0.6333 0 ) // Post q3map2 Fix
   q3map_tcmod scale 1 1 // <---------------- change these numbers for the scaling you want
   q3map_tcMod rotate 30

   {
      map textures/cliffwall/dirtyrock_gray_dark.tga // Primary
   }

   {
      map textures/bztourny/arkhart-grass2.png // Secondary
      blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA     
      alphaGen vertex
   }

   {
      map $lightmap
      blendFunc GL_DST_COLOR GL_ZERO
   }
}



pinkshine
{
	dpglossintensitymod  2
	dpglossexponentmod  4
	dpreflectcube env/exomorph/exomorph
	{
		map textures/pinkshine.tga 
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}
}



tigerstripesgoldcoppermetal1
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tigerstripesgoldcoppermetal.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}



tigerstripesmetalcm1
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tigerstripesmetalcm.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

tigerstripesmetalsilver1
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorph/exomorph
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tigerstripesmetalsilver.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

scopeglassbackgreenish1
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/scopeglassbackgreenish.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

scopeglassfrontr2o1
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/scopeglassfrontr2o.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}



ak47silver
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/ak47silver.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}



ak47gold
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/ak47gold.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}



tt33texsilver
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tt33texsilver.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}



tt33texgold
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tt33texgold.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

tt33texred
{	
	//This one has gloss modifiers set
	dpglossintensitymod  2.25
	dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/tt33texred.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


mp5kpdwtex
{	
	//This one has gloss modifiers set
	//dpglossintensitymod  2.25
	//dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/mp5kpdwtex.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}




mp5kpdwtexcm
{	
	//Colormapped version
	//This one has gloss modifiers set
	//dpglossintensitymod  2.25
	//dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/mp5kpdwtexcm.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}


mp5kpdwtexshining
{	
	//Colormapped version
	//This one has gloss modifiers set
	//dpglossintensitymod  2.25
	//dpglossexponentmod  2.75
	dpreflectcube env/exomorphdesat/exomorphdesat
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/mp5kpdwtexshining.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}
