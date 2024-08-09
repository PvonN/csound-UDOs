;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sine_beatings
;;; - creates sine tones with rhythmic beatings; uses sine function
;;; instead of a wavetable 
;;; - kAmp -> output amplitude
;;; - kFreq -> base freq
;;; - kBeatings -> number of beatings per second
opcode sine_beatings,a,kkk
  ;; sine synthesizer for creating beatings
  ;; kBeatings = number of beatings per second
  ;; sine waves are made with sine functions and not with wavetable
  kAmp,kFreq,kBeatings xin
  
  kFreq1 = kFreq+(kBeatings/2)
  kFreq2 = kFreq-(kBeatings/2)
  aSin1 = sin(phasor:a(kFreq1)*2*$M_PI)
  aSin2 = sin(phasor:a(kFreq2)*2*$M_PI)
  aSin1 *= 0.5
  aSin2 *= 0.5

  aSin sum aSin1,aSin2
  aSin *= kAmp
  xout aSin
;; by philipp von neumann
endop

