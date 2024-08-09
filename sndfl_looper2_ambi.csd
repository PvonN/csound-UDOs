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
#include "sndfl_looper2_ambi.udo"
;-----------------------------------------------------------
instr 1
  ;; load soundfile
  SndFl = "yourSndfl.wav"

  ;; parameter
  kSpeed = 1
  kLoopStart linseg 0,p3,1
  kLoopSize = 0.008
  kStereoOffset = 0.5
  iHanning ftgen 0,0,4096,20,2,1
  iWndwFt = iHanning
  kAzi linseg 0,p3,360
  kAlti linseg 90,p3,0
  kMaskArr[] fillarray 1,0,0,1,1,1,1,0,0,1,0,0,1,0,0,0,0,1,1,1
  iOrder = 3
  
  ;; sound generation
  aOutputArr[] init (iOrder+1)^2
  aOutputArr sndfl_looper2_ambi \
    SndFl,kSpeed,kLoopStart,kLoopSize,kStereoOffset,iWndwFt,kAzi,kAlti,kMaskArr,iOrder

  ;; rendering
  fout "yourRenderFile.wav",-1,aOutputArr
  
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 10
</CsScore>
</CsoundSynthesizer>
;; by philipp von neumann