ltnggun
{
	dpglossexponentmod  64
	dpreflectcube env/exomorph/exomorph
 	{
		map textures/ltnggun.tga
		rgbgen lightingDiffuse
	}
}

torch_fire
{
	surfaceparm trans
	surfaceparm noimpact
	deformVertexes wave 2 sin 0 0.2 0.25 0.2
	Q3map_TessSize 128
	cull disable
	{
		map textures/torch_fire.tga
		blendFunc add
		//rgbGen identity
	}
}
//3.3.1 deformVertexes wave <div> <func> <base> <amplitude> <phase> <freq>
//Designed for water surfaces, modifying the values differently at each point. //It accepts the standard wave functions of the type sin, triangle, square, //sawtooth or inversesawtooth. The "div" parameter is used to control the wave //"spread" - a value equal to the tessSize of the surface is a good default //value (tessSize is subdivision size, in game units, used for the shader when //seen in the game world) .

