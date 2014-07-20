;
; File generated by cc65 v 2.13.3
;
	.fopt		compiler,"cc65 v 2.13.3"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	off
	.importzp	sp, sreg, regsave, regbank, tmp1, ptr1, ptr2
	.macpack	longbranch
	.import		_strcat
	.import		_strcpy
	.import		_memcmp
	.import		_ef3usb_send_str
	.import		_ef3usb_fread
	.import		_ef3usb_fclose
	.import		_utilAppendHex1
	.import		_utilAppendHex2
	.import		_utilAppendChar
	.export		_utilAppendStr
	.export		_utilAppendFlashAddr
	.export		_utilAppendDecimal
	.export		_utilOpenFile
	.export		_utilCloseFile
	.import		_utilInitDecruncher
	.import		_utilReadEasySplitFile
	.export		_utilRead
	.import		_nUtilExoBytesRemaining
	.export		_utilStr
	.import		_g_nDrive
	.import		_g_strFileName
	.import		_fileDlg
	.import		_screenBing
	.import		_screenPrintDialog
	.import		_screenPrintSimpleDialog
	.import		_screenPrintTwoLinesDialog
	.import		_apStrFileNoEasySplit
	.import		_apStrDifferentFile
	.import		_g_bFastLoaderEnabled
	.import		_refreshMainScreen
	.import		_eload_set_drive_check_fastload
	.import		_eload_set_drive_disable_fastload
	.import		_eload_open_read
	.import		_eload_read_byte
	.import		_eload_read
	.import		_eload_close
	.import		_timerStop
	.import		_timerCont
	.import		_g_nSlots
	.export		_utilAskForNextFile

.segment	"RODATA"

_aEasySplitSignature:
	.byte	$65
	.byte	$61
	.byte	$73
	.byte	$79
	.byte	$73
	.byte	$70
	.byte	$6C
	.byte	$74
L0001:
	.byte	$4C,$4F,$41,$44,$00,$C9,$46,$20,$59,$4F,$55,$20,$52,$45,$41,$4C
	.byte	$4C,$59,$20,$57,$41,$4E,$54,$00,$54,$4F,$20,$41,$42,$4F,$52,$54
	.byte	$2C,$20,$50,$52,$45,$53,$53,$20,$3C,$D3,$54,$4F,$50,$3E,$2E,$00
	.byte	$D4,$48,$49,$53,$20,$49,$53,$20,$4E,$4F,$54,$20,$50,$41,$52,$54
	.byte	$20,$00,$D3,$45,$4C,$45,$43,$54,$20,$54,$48,$45,$20,$52,$49,$47
	.byte	$48,$54,$20,$50,$41,$52,$54,$2E,$00

.segment	"BSS"

_utilStr:
	.res	80,$00
_utilRead:
	.res	2,$00
_m_uFileHeader:
	.res	16,$00
_nCurrentPart:
	.res	1,$00
_nCurrentFileId:
	.res	2,$00
_bUseUSB:
	.res	1,$00

; ---------------------------------------------------------------
; void __near__ __fastcall__ utilAppendStr (__near__ const unsigned char*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilAppendStr: near

.segment	"CODE"

;
; {
;
	jsr     pushax
;
; strcat(utilStr, str);
;
	lda     #<(_utilStr)
	ldx     #>(_utilStr)
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     _strcat
;
; }
;
	jmp     incsp2

.endproc

; ---------------------------------------------------------------
; void __near__ __fastcall__ utilAppendFlashAddr (__near__ const struct EasyFlashAddr_s*)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilAppendFlashAddr: near

.segment	"CODE"

;
; {
;
	jsr     pushax
;
; if (g_nSlots > 1)
;
	lda     _g_nSlots
	cmp     #$02
	bcc     L007A
;
; utilAppendHex2(pAddr->nSlot);
;
	jsr     ldax0sp
	sta     ptr1
	stx     ptr1+1
	ldy     #$00
	lda     (ptr1),y
	jsr     _utilAppendHex2
;
; utilAppendChar(':');
;
	lda     #$3A
	jsr     _utilAppendChar
;
; utilAppendHex2(pAddr->nBank & FLASH_BANK_MASK);
;
L007A:	jsr     ldax0sp
	sta     ptr1
	stx     ptr1+1
	ldy     #$01
	lda     (ptr1),y
	and     #$3F
	jsr     _utilAppendHex2
;
; utilAppendChar(':');
;
	lda     #$3A
	jsr     _utilAppendChar
;
; utilAppendHex1(pAddr->nChip);
;
	jsr     ldax0sp
	sta     ptr1
	stx     ptr1+1
	ldy     #$02
	lda     (ptr1),y
	jsr     _utilAppendHex1
;
; utilAppendChar(':');
;
	lda     #$3A
	jsr     _utilAppendChar
;
; utilAppendHex2(pAddr->nOffset >> 8);
;
	jsr     ldax0sp
	ldy     #$04
	jsr     ldaxidx
	txa
	jsr     _utilAppendHex2
;
; utilAppendHex2(pAddr->nOffset);
;
	jsr     ldax0sp
	sta     ptr1
	stx     ptr1+1
	ldy     #$03
	lda     (ptr1),y
	jsr     _utilAppendHex2
;
; }
;
	jmp     incsp2

.endproc

; ---------------------------------------------------------------
; void __near__ __fastcall__ utilAppendDecimal (unsigned int)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilAppendDecimal: near

.segment	"BSS"

L008F:
	.res	5,$00
L0090:
	.res	1,$00

.segment	"CODE"

;
; {
;
	jsr     pushax
;
; if (n)
;
	ldy     #$01
	lda     (sp),y
	dey
	ora     (sp),y
	beq     L0091
;
; i = 0;
;
	sty     L0090
;
; while (n)
;
L0095:	ldy     #$01
	lda     (sp),y
	dey
	ora     (sp),y
	beq     L0096
;
; aNum[i++] = n % 10;
;
	ldx     #$00
	lda     L0090
	bpl     L009A
	dex
L009A:	pha
	clc
	adc     #$01
	sta     L0090
	pla
	clc
	adc     #<(L008F)
	tay
	txa
	adc     #>(L008F)
	tax
	tya
	jsr     pushax
	ldy     #$05
	jsr     pushwysp
	lda     #$0A
	jsr     tosumoda0
	ldy     #$00
	jsr     staspidx
;
; n /= 10;
;
	jsr     pushw0sp
	lda     #$0A
	jsr     tosudiva0
	jsr     stax0sp
;
; }
;
	jmp     L0095
;
; while (--i >= 0)
;
L0096:	dec     L0090
	ldx     L0090
	jmi     incsp2
;
; utilAppendChar('0' + aNum[i]);
;
	ldy     L0090
	ldx     #$00
	lda     L008F,y
	ldy     #$30
	jsr     incaxy
	jsr     _utilAppendChar
;
; }
;
	jmp     L0096
;
; utilAppendChar('0');
;
L0091:	lda     #$30
	jsr     _utilAppendChar
;
; }
;
	jmp     incsp2

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ utilOpenFile (unsigned char)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilOpenFile: near

.segment	"BSS"

L001C:
	.res	1,$00

.segment	"CODE"

;
; if (nPart == UTIL_USE_USB)
;
	ldy     #$00
	lda     (sp),y
	cmp     #$FE
	bne     L001D
;
; ef3usb_send_str("load");
;
	lda     #<(L0001)
	ldx     #>(L0001)
	jsr     _ef3usb_send_str
;
; utilRead = ef3usb_fread;
;
	lda     #<(_ef3usb_fread)
	sta     _utilRead
	lda     #>(_ef3usb_fread)
	sta     _utilRead+1
;
; bUseUSB = 1;
;
	lda     #$01
	sta     _bUseUSB
;
; return OPEN_FILE_OK;
;
	ldx     #$00
	txa
	jmp     incsp1
;
; bUseUSB = 0;
;
L001D:	sty     _bUseUSB
;
; if (g_bFastLoaderEnabled)
;
	lda     _g_bFastLoaderEnabled
	beq     L0028
;
; eload_set_drive_check_fastload(g_nDrive);
;
	lda     _g_nDrive
	jsr     _eload_set_drive_check_fastload
;
; else
;
	jmp     L002C
;
; eload_set_drive_disable_fastload(g_nDrive);
;
L0028:	lda     _g_nDrive
	jsr     _eload_set_drive_disable_fastload
;
; type = utilCheckFileHeader();
;
L002C:	jsr     _utilCheckFileHeader
	sta     L001C
;
; if (type == OPEN_FILE_ERR)
;
	cmp     #$01
	bne     L0031
;
; return type;
;
	ldx     #$00
	lda     L001C
	jmp     incsp1
;
; if (nPart == 0)
;
L0031:	ldy     #$00
	lda     (sp),y
	bne     L0034
;
; if (type == OPEN_FILE_TYPE_ESPLIT)
;
	lda     L001C
	cmp     #$08
	bne     L0036
;
; return utilOpenEasySplitFile(nPart);
;
	lda     (sp),y
	jsr     _utilOpenEasySplitFile
	jmp     incsp1
;
; utilRead = eload_read;
;
L0036:	lda     #<(_eload_read)
	sta     _utilRead
	lda     #>(_eload_read)
	sta     _utilRead+1
;
; return utilOpenELoadFile();
;
	jsr     _utilOpenELoadFile
	jmp     incsp1
;
; if (type != OPEN_FILE_TYPE_ESPLIT)
;
L0034:	lda     L001C
	cmp     #$08
	beq     L003F
;
; screenPrintSimpleDialog(apStrFileNoEasySplit);
;
	lda     #<(_apStrFileNoEasySplit)
	ldx     #>(_apStrFileNoEasySplit)
	jsr     _screenPrintSimpleDialog
;
; return OPEN_FILE_WRONG;
;
	ldx     #$00
	lda     #$02
	jmp     incsp1
;
; return utilOpenEasySplitFile(nPart);
;
L003F:	lda     (sp),y
	jsr     _utilOpenEasySplitFile
	jmp     incsp1

.endproc

; ---------------------------------------------------------------
; void __near__ utilCloseFile (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilCloseFile: near

.segment	"CODE"

;
; if (bUseUSB)
;
	lda     _bUseUSB
	jeq     _eload_close
;
; ef3usb_fclose();
;
	jmp     _ef3usb_fclose

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ utilCheckFileHeader (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilCheckFileHeader: near

.segment	"BSS"

L00E8:
	.res	1,$00

.segment	"CODE"

;
; if (eload_open_read(g_strFileName) != 0)
;
	lda     #<(_g_strFileName)
	ldx     #>(_g_strFileName)
	jsr     _eload_open_read
	cpx     #$00
	bne     L0119
	cmp     #$00
	beq     L00E9
;
; return OPEN_FILE_ERR;
;
L0119:	ldx     #$00
	lda     #$01
	rts
;
; len = eload_read(&m_uFileHeader, sizeof(m_uFileHeader));
;
L00E9:	lda     #<(_m_uFileHeader)
	ldx     #>(_m_uFileHeader)
	jsr     pushax
	ldx     #$00
	lda     #$10
	jsr     _eload_read
	sta     L00E8
;
; eload_close();
;
	jsr     _eload_close
;
; if (len != sizeof(m_uFileHeader))
;
	lda     L00E8
	cmp     #$10
;
; return OPEN_FILE_UNKNOWN;
;
	bne     L00F8
;
; if (memcmp(m_uFileHeader.easySplitHeader.magic,
;
	lda     #<(_m_uFileHeader)
	ldx     #>(_m_uFileHeader)
	jsr     pushax
;
; aEasySplitSignature, sizeof(aEasySplitSignature)) == 0)
;
	lda     #<(_aEasySplitSignature)
	ldx     #>(_aEasySplitSignature)
	jsr     pushax
	ldx     #$00
	lda     #$08
	jsr     _memcmp
	cpx     #$00
	bne     L00F8
	cmp     #$00
	bne     L00F8
;
; return OPEN_FILE_TYPE_ESPLIT;
;
	lda     #$08
	rts
;
; return OPEN_FILE_UNKNOWN;
;
L00F8:	ldx     #$00
	lda     #$03
;
; }
;
	rts

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ __fastcall__ utilOpenEasySplitFile (unsigned char)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilOpenEasySplitFile: near

.segment	"BSS"

L00B7:
	.res	1,$00
L00B8:
	.res	1,$00

.segment	"CODE"

;
; {
;
	jsr     pusha
;
; if (nPart != m_uFileHeader.easySplitHeader.part)
;
	ldy     #$00
	lda     (sp),y
	cmp     _m_uFileHeader+14
	beq     L00B9
;
; utilComplainWrongPart(nPart);
;
	lda     (sp),y
	jsr     pusha
	jsr     _utilComplainWrongPart
;
; return OPEN_FILE_WRONG;
;
	ldx     #$00
	lda     #$02
	jmp     incsp1
;
; if ((nPart != 0) &&
;
L00B9:	lda     (sp),y
	beq     L00BE
;
; (nCurrentFileId != *(uint16_t*)(m_uFileHeader.easySplitHeader.id)))
;
	lda     _m_uFileHeader+12
	ldx     _m_uFileHeader+12+1
	cpx     _nCurrentFileId+1
	bne     L00BF
	cmp     _nCurrentFileId
	beq     L00BE
;
; screenPrintDialog(apStrDifferentFile, BUTTON_ENTER);
;
L00BF:	lda     #<(_apStrDifferentFile)
	ldx     #>(_apStrDifferentFile)
	jsr     pushax
	lda     #$01
	jsr     _screenPrintDialog
;
; return OPEN_FILE_WRONG;
;
	ldx     #$00
	lda     #$02
	jmp     incsp1
;
; utilRead = utilReadEasySplitFile;
;
L00BE:	lda     #<(_utilReadEasySplitFile)
	sta     _utilRead
	lda     #>(_utilReadEasySplitFile)
	sta     _utilRead+1
;
; rv = utilOpenELoadFile();
;
	jsr     _utilOpenELoadFile
	sta     L00B8
;
; if (rv != OPEN_FILE_OK)
;
	lda     L00B8
	beq     L00CD
;
; return rv;
;
	ldx     #$00
	lda     L00B8
	jmp     incsp1
;
; for (i = 0; i < sizeof(EasySplitHeader); ++i)
;
L00CD:	sta     L00B7
L00D0:	lda     L00B7
	cmp     #$10
	bcs     L00D1
;
; eload_read_byte();
;
	jsr     _eload_read_byte
;
; for (i = 0; i < sizeof(EasySplitHeader); ++i)
;
	inc     L00B7
	jmp     L00D0
;
; if (nPart == 0)
;
L00D1:	ldy     #$00
	lda     (sp),y
	bne     L00D9
;
; *(uint32_t*)(m_uFileHeader.easySplitHeader.len);
;
	lda     _m_uFileHeader+8+3
	sta     sreg+1
	lda     _m_uFileHeader+8+2
	sta     sreg
	ldx     _m_uFileHeader+8+1
	lda     _m_uFileHeader+8
	sta     _nUtilExoBytesRemaining
	stx     _nUtilExoBytesRemaining+1
	ldy     sreg
	sty     _nUtilExoBytesRemaining+2
	ldy     sreg+1
	sty     _nUtilExoBytesRemaining+3
;
; nUtilExoBytesRemaining = -nUtilExoBytesRemaining - 1;
;
	lda     _nUtilExoBytesRemaining+3
	sta     sreg+1
	lda     _nUtilExoBytesRemaining+2
	sta     sreg
	ldx     _nUtilExoBytesRemaining+1
	lda     _nUtilExoBytesRemaining
	jsr     negeax
	ldy     #$01
	jsr     deceaxy
	sta     _nUtilExoBytesRemaining
	stx     _nUtilExoBytesRemaining+1
	ldy     sreg
	sty     _nUtilExoBytesRemaining+2
	ldy     sreg+1
	sty     _nUtilExoBytesRemaining+3
;
; utilInitDecruncher();
;
	jsr     _utilInitDecruncher
;
; nCurrentFileId = *(uint16_t*)(m_uFileHeader.easySplitHeader.id);
;
	lda     _m_uFileHeader+12
	sta     _nCurrentFileId
	lda     _m_uFileHeader+12+1
	sta     _nCurrentFileId+1
;
; nCurrentPart = nPart;
;
L00D9:	ldy     #$00
	lda     (sp),y
	sta     _nCurrentPart
;
; return OPEN_FILE_OK;
;
	ldx     #$00
	txa
;
; }
;
	jmp     incsp1

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ utilOpenELoadFile (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilOpenELoadFile: near

.segment	"CODE"

;
; if (eload_open_read(g_strFileName) == 0)
;
	lda     #<(_g_strFileName)
	ldx     #>(_g_strFileName)
	jsr     _eload_open_read
	cpx     #$00
	bne     L00AF
	cmp     #$00
	bne     L00AF
;
; return OPEN_FILE_OK;
;
	rts
;
; return OPEN_FILE_ERR;
;
L00AF:	ldx     #$00
	lda     #$01
;
; }
;
	rts

.endproc

; ---------------------------------------------------------------
; void __near__ utilComplainWrongPart (unsigned char)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilComplainWrongPart: near

.segment	"BSS"

L0103:
	.res	6,$00

.segment	"CODE"

;
; strcpy(utilStr, "This is not part ");
;
	ldy     #$FF
L0107:	iny
	lda     L0001+48,y
	sta     _utilStr,y
	bne     L0107
;
; utilAppendHex2(nPart + 1);
;
	ldy     #$00
	lda     (sp),y
	clc
	adc     #$01
	jsr     _utilAppendHex2
;
; utilAppendChar('.');
;
	lda     #$2E
	jsr     _utilAppendChar
;
; apStr[0] = utilStr;
;
	lda     #<(_utilStr)
	sta     L0103
	lda     #>(_utilStr)
	sta     L0103+1
;
; apStr[1] = "Select the right part.";
;
	lda     #<(L0001+66)
	sta     L0103+2
	lda     #>(L0001+66)
	sta     L0103+2+1
;
; apStr[2] = NULL;
;
	lda     #$00
	sta     L0103+4
	sta     L0103+4+1
;
; screenPrintDialog(apStr, BUTTON_ENTER);
;
	lda     #<(L0103)
	ldx     #>(L0103)
	jsr     pushax
	lda     #$01
	jsr     _screenPrintDialog
;
; }
;
	jmp     incsp1

.endproc

; ---------------------------------------------------------------
; unsigned char __near__ utilAskForNextFile (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_utilAskForNextFile: near

.segment	"BSS"

L004F:
	.res	3,$00
L0050:
	.res	1,$00

.segment	"CODE"

;
; eload_close();
;
	jsr     _eload_close
;
; timerStop();
;
	jsr     _timerStop
;
; ++nCurrentPart;
;
	inc     _nCurrentPart
;
; utilStr[0] = '\0';
;
	lda     #$00
	sta     _utilStr
;
; utilAppendHex2(nCurrentPart + 1);
;
	lda     _nCurrentPart
	clc
	adc     #$01
	jsr     _utilAppendHex2
;
; strcpy(str, utilStr);
;
	ldy     #$FF
L005C:	iny
	lda     _utilStr,y
	sta     L004F,y
	bne     L005C
;
; screenBing();
;
L005D:	jsr     _screenBing
;
; refreshMainScreen();
;
	jsr     _refreshMainScreen
;
; ret = fileDlg(str);
;
	lda     #<(L004F)
	ldx     #>(L004F)
	jsr     _fileDlg
	sta     L0050
;
; if (!ret)
;
	lda     L0050
	bne     L006E
;
; ret = screenPrintTwoLinesDialog("If you really want",
;
	lda     #<(L0001+5)
	ldx     #>(L0001+5)
	jsr     pushax
;
; "to abort, press <Stop>.");
;
	lda     #<(L0001+24)
	ldx     #>(L0001+24)
	jsr     _screenPrintTwoLinesDialog
	sta     L0050
;
; if (ret == BUTTON_STOP)
;
	cmp     #$02
	bne     L006E
;
; return 0;
;
	ldx     #$00
	txa
	rts
;
; while (!ret);
;
L006E:	lda     L0050
	beq     L005D
;
; ret = utilOpenFile(nCurrentPart);
;
	lda     _nCurrentPart
	jsr     pusha
	jsr     _utilOpenFile
	sta     L0050
;
; while (ret != OPEN_FILE_OK);
;
	lda     L0050
	bne     L005D
;
; timerCont();
;
	jsr     _timerCont
;
; refreshMainScreen();
;
	jsr     _refreshMainScreen
;
; return 1;
;
	ldx     #$00
	lda     #$01
;
; }
;
	rts

.endproc

