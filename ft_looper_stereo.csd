<CsoundSynthesizer>
<CsOptions>
-odac 
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 16
nchnls = 2
0dbfs = 1.0

#include "./ft_looper_stereo.udo"

instr 1
  Sndfl = "./DasWetter.wav"
  iSound ftgen 0, 0, 0, 1, Sndfl, 0, 0, 0 
  iPhaseDist ftgen 0, 0, 4096, -7, 0, 2048, 0.75, 2048, 1
  iHanning ftgen 0, 0, 4096, 20, 2, 1
  
  // ft_looper
  iFt = iSound
  kSpeed = 1
  kStart line 0, p3, 1
  kSize randomi 250, 500, 3
  iOffset = 0.5
  iWndFt = iHanning
  iPhFt = iPhaseDist
  kMaskArr[] fillarray 1, 1
  aSig1, aSig2 ft_looper_stereo iFt, kSpeed, kStart, kSize, iOffset,\
    iWndFt, iPhFt, kMaskArr

  // output
  aOut1 = aSig1
  aOut2 = aSig2
  outs aOut1, aOut2
endin

</CsInstruments>
<CsScore>
i1 0 10
</CsScore>
</CsoundSynthesizer>
