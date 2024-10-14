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
#include "contrast_enhancement.udo"
;-----------------------------------------------------------
instr 1
  ;; sine wave
  kAmp = 0.9
  kFreq = 440
  aSine poscil3 kAmp, kFreq

  ;; contrast enhancement
  kAmount linseg 0, p3 * 0.75, 2, p3 * 0.25, 2
  aSine contrast_enhancement aSine, kAmount
  
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
