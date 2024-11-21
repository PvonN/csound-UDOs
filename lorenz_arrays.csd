<CsoundSynthesizer>
<CsOptions>
-d -odac -W -3
</CsOptions>
<CsInstruments>

sr = 96000
ksmps = 16
nchnls = 2
0dbfs = 1.0

#include "./lorenz_arrays.udo"

instr 1
  iSize = 16384

  iX random -1, 1
  iY random -1, 1
  iZ random -1, 1
  iStepSize = 10
  iXarr[], iYarr[], iZarr[] lorenz_arrays iSize, iX, iY, iZ, iStepSize

  scalearray iXarr, -1, 1
  scalearray iYarr, -1, 1
  scalearray iZarr, -1, 1

  iXft ftgen 0, 0, iSize, 2, 0
  iYft ftgen 0, 0, iSize, 2, 0
  iZft ftgen 0, 0, iSize, 2, 0
  
  copya2ftab iXarr, iXft
  copya2ftab iYarr, iYft
  copya2ftab iZarr, iZft

  aPhasor line 0, p3, 1
  aX_Sig table3 aPhasor, iXft, 1
  aY_Sig table3 aPhasor, iYft, 1
  aZ_Sig table3 aPhasor, iZft, 1

  fout "./waveform-test.wav", -1, aX_Sig, aY_Sig, aZ_Sig
endin

</CsInstruments>
<CsScore>
i1 0 1
</CsScore>
</CsoundSynthesizer>
