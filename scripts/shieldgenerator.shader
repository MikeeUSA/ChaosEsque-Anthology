textures/shieldcolored
{
	qer_editorimage textures/shieldcolored.tga
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/shieldcolored.tga
		blendfunc add
		tcGen environment
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}
