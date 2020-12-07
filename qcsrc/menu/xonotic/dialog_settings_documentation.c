#ifdef INTERFACE
CLASS(XonoticDocumentationSettingsTab) EXTENDS(XonoticTab)
	METHOD(XonoticDocumentationSettingsTab, fill, void(entity))
	ATTRIB(XonoticDocumentationSettingsTab, title, string, _("Documentation"))
	ATTRIB(XonoticDocumentationSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticDocumentationSettingsTab, rows, float, 17)
	ATTRIB(XonoticDocumentationSettingsTab, columns, float, 6) // added extra .2 for center space 
ENDCLASS(XonoticDocumentationSettingsTab)
entity makeXonoticDocumentationSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticDocumentationSettingsTab()
{
	entity me;
	me = spawnXonoticDocumentationSettingsTab();
	me.configureDialog(me);
	return me;
}
void XonoticDocumentationSettingsTab_fill(entity me)
{
	entity e;
	entity kb;

	me.TR(me);
		me.TD(me, me.rows - 1, 6, kb = makeXonoticDocumentationList());
}
#endif
