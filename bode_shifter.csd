<CsoundSynthesizer>
<CsOptions>
-d -odac -W -3
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1.0

#include "./bode_shifter.udo"

giSine ftgen 0,0,4096,10,1

instr 1  // example for basic pitch shifting of a sine wave
  aSine poscil 0.8, 440

  aShiftIn = aSine
  kShiftFreq =  220
  aDownShift, aUpShift bode_shifter aShiftIn, kShiftFreq, giSine

  // output
  aSum sum aSine/3, aDownShift/3, aUpShift/3
  out aSum
endin

</CsInstruments>
<CsScore>
i1 0 10
</CsScore>
</CsoundSynthesizer>
