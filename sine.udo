;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sine
;;; - creates sine wave and uses the sine function instead of a
;;; wavetable
;;; - kAmp -> output amplitude
;;; - kFreq -> base freq
opcode sine,a,kk
  kAmp,kFreq xin
  aSine = sin(phasor:a(kFreq)*2*$M_PI)
  aSine *= kAmp
  xout aSine
  ;; by philipp von neumann
endop

