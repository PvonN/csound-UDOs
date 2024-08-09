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
#include "sine.udo"
;-----------------------------------------------------------
instr 1
  ;; sine wave
  kAmp = 0.7
  kFreq linseg 110,p3/2,440,p3/2,80
  aSine sine kAmp,kFreq

  ;; output
  aOut = aSine
  outs aOut,aOut
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 10
</CsScore>
</CsoundSynthesizer>
;; by von neumann
