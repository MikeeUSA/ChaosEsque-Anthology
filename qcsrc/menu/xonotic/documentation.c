#ifdef INTERFACE
CLASS(XonoticDocumentationList) EXTENDS(XonoticListBox)
	METHOD(XonoticDocumentationList, configureXonoticDocumentationList, void(entity))
	ATTRIB(XonoticDocumentationList, rowsPerItem, float, 1)
	METHOD(XonoticDocumentationList, draw, void(entity))
	METHOD(XonoticDocumentationList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticDocumentationList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticDocumentationList, keyDown, float(entity, float, float, float))
	METHOD(XonoticDocumentationList, destroy, void(entity))

	ATTRIB(XonoticDocumentationList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticDocumentationList, realUpperMargin, float, 0)
	ATTRIB(XonoticDocumentationList, bufferIndex, float, 0)
	ATTRIB(XonoticDocumentationList, scrolling, float, 0)

	ATTRIB(XonoticListBox, alphaBG, float, 0)
ENDCLASS(XonoticDocumentationList)
entity makeXonoticDocumentationList();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticDocumentationList()
{
	entity me;
	me = spawnXonoticDocumentationList();
	me.configureXonoticDocumentationList(me);
	return me;
}
void XonoticDocumentationList_configureXonoticDocumentationList(entity me)
{
	me.configureXonoticListBox(me);
	// load the file
	me.bufferIndex = buf_load(language_filename("documentation.txt"));
	me.nItems = buf_getsize(me.bufferIndex);
}
void XonoticDocumentationList_destroy(entity me)
{
	buf_del(me.bufferIndex);
}
void XonoticDocumentationList_draw(entity me)
{
	float i;
	if(me.scrolling)
	{
		me.scrollPos = bound(0, (time - me.scrolling) * me.itemHeight, me.nItems * me.itemHeight - 1);
		i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
		i = max(i, ceil(me.scrollPos / me.itemHeight));
		me.setSelected(me, i);
	}
	SUPER(XonoticDocumentationList).draw(me);
}
void XonoticDocumentationList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(XonoticDocumentationList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}
void XonoticDocumentationList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Credits name, Map name, NP, TP, MP
	string s;
	float theAlpha;
	vector theColor;

	s = bufstr_get(me.bufferIndex, i);

	if(substring(s, 0, 2) == "**")
	{
		s = substring(s, 2, strlen(s) - 2);
		theColor = SKINCOLOR_CREDITS_TITLE;
		theAlpha = SKINALPHA_CREDITS_TITLE;
	}
	else if(substring(s, 0, 1) == "*")
	{
		s = substring(s, 1, strlen(s) - 1);
		theColor = SKINCOLOR_CREDITS_FUNCTION;
		theAlpha = SKINALPHA_CREDITS_FUNCTION;
	}
	else
	{
		theColor = SKINCOLOR_CREDITS_PERSON;
		theAlpha = SKINALPHA_CREDITS_PERSON;
	}

	//draw_CenterText(me.realUpperMargin * eY + 0.5 * eX, s, me.realFontSize, theColor, theAlpha, 0);
	draw_Text(me.realUpperMargin * eY + 0 * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float XonoticDocumentationList_keyDown(entity me, float key, float ascii, float shift)
{
	float i;
	me.dragScrollTimer = time;
	me.scrolling = 0;
	if(key == K_PGUP || key == K_KP_PGUP)
		me.scrollPos = max(me.scrollPos - 0.5, 0);
	else if(key == K_PGDN || key == K_KP_PGDN)
		me.scrollPos = min(me.scrollPos + 0.5, me.nItems * me.itemHeight - 1);
	else if(key == K_UPARROW || key == K_KP_UPARROW)
		me.scrollPos = max(me.scrollPos - me.itemHeight, 0);
	else if(key == K_DOWNARROW || key == K_KP_DOWNARROW)
		me.scrollPos = min(me.scrollPos + me.itemHeight, me.nItems * me.itemHeight - 1);
	else
		return SUPER(XonoticDocumentationList).keyDown(me, key, ascii, shift);

	i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
	i = max(i, ceil(me.scrollPos / me.itemHeight));
	me.setSelected(me, i);

	return 1;
}
#endif
