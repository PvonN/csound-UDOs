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
#include "sine_beatings.udo"
;-----------------------------------------------------------
instr 1
  ;; signal
  kAmp = 0.9
  kFreq = 100
  kBeatings linseg 3,p3/2,3,p3/4,200,p3/4,3
  aSig sine_beatings kAmp,kFreq,kBeatings

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
;; by philipp von neumann