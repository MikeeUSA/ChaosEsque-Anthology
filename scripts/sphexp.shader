models/sphere/sphexp
{
	surfaceparm trans
	//dpglossintensitymod  2
	//dpglossexponentmod  4
	cull disable
	{
		map models/sphere/sphexp.tga
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}	
}

sphexp2
{
	surfaceparm trans
	cull disable
	{
		map textures/sphexp2.tga
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}	
}

sphexp3
{
	surfaceparm trans
	cull disable
	{
		map textures/sphexp3.tga
	}
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
		blendfunc filter
	}	
}
