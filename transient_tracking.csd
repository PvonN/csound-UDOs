<CsoundSynthesizer>
<CsOptions>
-d -odac -W -3
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1.0

#include "./transient_tracking.udo"

instr 1
  aSignal phasor 30

  kTrig transient_tracking aSignal, 0.25

  printk2 kTrig
endin

</CsInstruments>
<CsScore>
i1 0 10
</CsScore>
</CsoundSynthesizer>
