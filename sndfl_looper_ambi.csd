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
#include "sndfl_looper_ambi.udo"
;-----------------------------------------------------------
instr 1
  ;; soundfile
  SndFl = "yourSndfl.wav"

  ;; parameter for sndfl looping
  kSpeed = 1
  kLoopStart linseg 0,p3,1
  kLoopSize = 0.01
  kStereoOffset = 0.5
  iHanning ftgen 0,0,8192,20,2,1
  iWndwFt = iHanning
  kAzi linseg 0,p3,360
  kAlti linseg 90,p3,0
  kMask oscil 1,0.5
  kMask = (kMask+1)/2
  iOrder = 3

  ;; soundfile looping
  ;; you need to initiate the output array
  aEncodedSignal[] init (iOrder+1)^2
  aEncodedSignal sndfl_looper_ambi \
    SndFl,kSpeed,kLoopStart,kLoopSize,kStereoOffset,iWndwFt,kAzi,kAlti,kMask,iOrder 

  ;; file rendering
  fout "pathForRendering.wav",-1,aEncodedSignal
  
endin
;-----------------------------------------------------------
</CsInstruments>
<CsScore>
i1 0 30
</CsScore>
</CsoundSynthesizer>
;; by philipp von neumann