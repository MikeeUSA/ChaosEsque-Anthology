#ifdef INTERFACE
CLASS(XonoticNocryptoDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticNocryptoDialog, fill, void(entity))
	ATTRIB(XonoticNocryptoDialog, title, string, _("Crypto Unsupported"))
	ATTRIB(XonoticNocryptoDialog, color, vector, SKINCOLOR_DIALOG_QUIT)
	ATTRIB(XonoticNocryptoDialog, intendedWidth, float, 0.7)
	ATTRIB(XonoticNocryptoDialog, rows, float, 28)
	ATTRIB(XonoticNocryptoDialog, columns, float, 2)
	ATTRIB(XonoticNocryptoDialog, name, string, "Quit")
ENDCLASS(XonoticNocryptoDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticNocryptoDialog_fill(entity me)
{
	entity e;
	me.TR(me);
	me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("If You Are Seeing This Dialogue Then There Is Only One Reasonable Explanation:")));
			e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me);
	me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("Encryption Is Not Supported by Engine Version :( You Should Take It Upon Yourself To")));
			e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("Compile A Version Of The Darkplaces Engine Which Supports AES Crypto. PostHaste")));
			e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me);
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("d0_blind_id supplies the code needed to enable cryptography in the engine"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("xonotic$ darkplaces d0_blind_id"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("xonotic$ ls d0_blind_id/"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("autogen.sh       d0_bignum.h          d0_blind_id.h      d0.h           d0_rijndael.h      Makefile.am"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("configure.ac     d0_bignum-openssl.c  d0_blind_id.pc.in  d0_iobuf.c     d0_rijndael.pc.in  sha2.c"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("COPYING          d0_bignum-tommath.c  d0_blind_id.txt    d0_iobuf.h     m4                 sha2.h"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("d0_bignum-gmp.c  d0_blind_id.c        d0.c               d0_rijndael.c  main.c"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me);
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("If you are using linux there may be precompiled binaries with support. Try:"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("START SCRIPT: xonotic-AESCrypto-linux-glx.sh OR xonotic-AESCrypto-linux-sdl.sh"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("64BITBINARIES: xonotic-AESCrypto-linux64-glx OR xonotic-AESCrypto-linux64-sdl"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("32BITBINARIES: xonotic-AESCrypto-linux32-glx OR xonotic-AESCrypto-linux32-sdl"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me);
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("If you are using windows the crypto libraries needs to reside"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("in the bin32 and/or bin64 directories under the xonotic folder."))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("xonotic/bin32:   libd0_rijndael-0.dll   libd0_blind_id-0.dll"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("xonotic/bin64:   libd0_rijndael-0.dll   libd0_blind_id-0.dll"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me);
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("If you are using MacOS the crypto libraries needs to reside"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("in the Xonotic.app/Contents/MacOS directory under the xonotic folder."))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("xonotic/Xonotic.app/Contents/MacOS:   libd0_blind_id.0.dylib"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TR(me); me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("libd0_blind_id.dylib   libd0_rijndael.0.dylib   libd0_rijndael.dylib"))); e.colorL = '1 0 0'; e.cvarOffValue = "0";

	me.TR(me);
		me.TD(me, 1, 2, makeXonoticTextLabel(0.5, _("Would you like to quit and go do that?")));
	//me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCommandButton(_("Yes"), '1 0 1', "echo ]quit\nquit", 0));
		me.TD(me, 1, 1, e = makeXonoticButton(_("No"), '1 1 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
