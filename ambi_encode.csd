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
;-----------------------------------------------------------
instr 1
  /* sound generation */
  aNoise pinkish 0.9

  /* encoding */
  iOrder = 5
  kAzi linseg 0,p3/2,360,p3/2,360
  kElv linseg 0,p3/2,0,p3/2,90
  aEncoded[] ambi_encode aNoise,iOrder,kAzi,kElv

  /* rendering */
  fout "encoded_noise.wav",-1,aEncoded
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 30
</CsScore>
</CsoundSynthesizer>
