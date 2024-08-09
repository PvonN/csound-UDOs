;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sine_oct
;;; - similiar to 'hsboscil' opcode but with sine-wave function instead
;;; of wavetable synthesis
;;; - generates a spectrum of sine waves in the distance of octaves;
;;; this spectrum is then windowed by a bandpass filter; the size of
;;; the bandpass filter is defined by kSize
;;; - kFreq -> BaseFreq
;;; - kCenter -> which partial is in center of the BP (0 = basefreq; 1 =
;;; first octave, and so on)  
;;; - kSize -> how big is the window in semitones up and down the
;;; octave (1 = 1 semitone down and up -> 2 semitones)
opcode sine_oct,a,kkk
  kFreq,kCenter,kSize xin
  
  ;; sine signals
  aSig0 = sin(phasor:a(kFreq)*2*$M_PI)
  aSig1 = sin(phasor:a(kFreq*2)*2*$M_PI)
  aSig2 = sin(phasor:a(kFreq*4)*2*$M_PI)
  aSig3 = sin(phasor:a(kFreq*8)*2*$M_PI)
  aSig4 = sin(phasor:a(kFreq*16)*2*$M_PI)
  aSig5 = sin(phasor:a(kFreq*32)*2*$M_PI)
  aSig6 = sin(phasor:a(kFreq*64)*2*$M_PI)
  aSig7 = sin(phasor:a(kFreq*128)*2*$M_PI)
  aSig8 = sin(phasor:a(kFreq*256)*2*$M_PI)
  aSig9 = sin(phasor:a(kFreq*512)*2*$M_PI)
  aSig10 = sin(phasor:a(kFreq*1024)*2*$M_PI)
  
  aSig sum \
    aSig0/11,aSig1/11,aSig2/11,aSig3/11,aSig4/11,aSig5/11,aSig6/11,aSig7/11,aSig8/11,aSig9/11,aSig10/11
  
  ;; bp filtering
  iFactor ftgen 0,0,0,-2,1,2,4,8,16,32,64,128,256,512,1024
  kPartial tablei kCenter,iFactor

  kCF = kPartial*kFreq
  kLP = kCF*2^(kSize/12)
  kHP = kCF*2^(-kSize/12)
  aLP butterlp aSig,limit:k(kLP,10,19999)
  aSine butterhp aLP,limit:k(kHP,10,19999)
  aSine balance aSine,aSig
  
  xout aSine
  ;; by philipp von neumann
endop


