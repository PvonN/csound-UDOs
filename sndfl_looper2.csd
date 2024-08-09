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
#include "sndfl_looper2.udo"
;-----------------------------------------------------------
instr 1
  ;; load your soundfile
  SndFl = "yourFile.wav"

  ;; parameter for soundfile looping
  kSpeed = 1
  kLoopStart linseg 0,p3,1
  kLoopSize = 0.005
  kStereoOffset = 0.5
  iHanning ftgen 0,0,8192,20,2,1
  iWndwFt = iHanning 
  kMask[] fillarray 1,1,1,0,1,0,0,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0

  ;; soundfile looping
  aSig1,aSig2 sndfl_looper2 \
    SndFl,kSpeed,kLoopStart,kLoopSize,kStereoOffset,iWndwFt,kMask

  ;; output
  aOut1 = aSig1
  aOut2 = aSig2
  outs aOut1,aOut2
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 30
</CsScore>
</CsoundSynthesizer>
;; by philipp von neumann