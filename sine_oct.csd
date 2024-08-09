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
#include "sine_oct.udo"
;-----------------------------------------------------------
instr 1
  ;; parameter
  kFreq = 65
  kCenter linseg 0,p3/2,5,p3/2,1
  kSize linseg 1,p3/2,32,p3/2,12
  ;; signal generation
  aSignal sine_oct kFreq,kCenter,kSize
  aSig1,aSig2 hilbert aSignal

  ;; output
  aOut1 = aSig1
  aOut2 = aSig2
  outs aSig1,aSig2
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 30
</CsScore>
</CsoundSynthesizer>
;; by philipp von neumann