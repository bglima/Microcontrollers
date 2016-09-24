; Credits: Harry (1and0)
; Found at http://www.microchip.com/forums/m790121.aspx
;
; CSEQF  skip if =
; CSGEF  skip if >=
; CSGTF  skip if >
; CSLEF  skip if <=
; CSLTF  skip if <
; CSNEF  skip if !=	  
	  
; Compare fr1 to fr2 and skip if =
CSEQF macro fr1,fr2
          movf fr2,w
          subwf fr1,w
          btfss STATUS,Z
          endm
;
; Compare fr1 to fr2 and skip if >=
CSGEF macro fr1,fr2
          movf fr2,w
          subwf fr1,w
          btfss STATUS,C
          endm
;
; Compare fr1 to fr2 and skip if >
CSGTF macro fr1,fr2
          movf fr1,w
          subwf fr2,w
          btfsc STATUS,C
          endm
;
; Compare fr1 to fr2 and skip if <=
CSLEF macro fr1,fr2
          movf fr1,w
          subwf fr2,w
          btfss STATUS,C
          endm
;
; Compare fr1 to fr2 and skip if <
CSLTF macro fr1,fr2
          movf fr2,w
          subwf fr1,w
          btfsc STATUS,C
          endm
;
; Compare fr1 to fr2 and skip if !=
CSNEF macro fr1,fr2
          movf fr2,w
          subwf fr1,w
          btfsc STATUS,Z
          endm
	  
