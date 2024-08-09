<CsoundSynthesizer>
<CsOptions>
-d -odac -W -3 
</CsOptions>
<CsInstruments>
sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1.0

;-----------------------------------------------------------
#include "ctrl_tbl.udo"
;-----------------------------------------------------------
instr 1
  ;; set the ctrl structure
  kPhasorSpeed linseg 1,p3/2,3,p3/4,1,p3/4,6
  aIndex phasor kPhasorSpeed
  SFile = "your.txt" ; use delicious algos for fine .txt file data
  iInterpol = 3
  aCtrl ctrl_tbl aIndex,SFile,iInterpol

  ;; ctrl whatever you like
  aSig poscil aCtrl,400

  ;; output
  aOut = aSig
  outs aOut,aOut
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 30
</CsScore>
</CsoundSynthesizer>
;;by philipp von neumann
