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
#include "ambi_encode.udo"
#include "ambi_spectrum.udo"
;-----------------------------------------------------------
instr 1
  ;; signal
  aSig pinkish 1

  ;; spatialisation
  aIn = aSig
  kMovement = 1
  kSpeed = 0.75
  iOrder = 3
  aEncdoedSignal[] init (iOrder+1)^2
  aEncodedSignal[] ambi_spectrum aIn,kMovement,kSpeed,iOrder

  ;; rendering
  fout "yourRenderPath.wav",-1,aEncodedSignal
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 10
</CsScore>
</CsoundSynthesizer>
;; by philipp von neumann
