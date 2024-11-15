/* bode_shifter
single-sideband modulation which results in frequency shifts
- named after harald bode (klangumwandler)
- aSum represents the downshifted signal
- aDiff represents the upshifted signel
*/
opcode bode_shifter, aa, aki
  /*
  - iWaveTable can take any Wavetable, but classic wavetable would be
  a sine
  - kModFreq is freq shift in Hz
  */
  aIn, kModFreq, iWaveTable xin

  aSin, aCos hilbert aIn
  aModSin poscil 1,kModFreq,iWaveTable,0.0
  aModCos poscil 1,kModFreq,iWaveTable,0.25
  aMod1 = aSin * aModCos
  aMod2 = aCos * aModSin
  aSum =  (aMod1 + aMod2) * (1.0 / sqrt(2.0))
  aDiff = (aMod1 - aMod2) * (1.0 / sqrt(2.0))

  xout aSum, aDiff
  ;; by PvN
endop

opcode bode_shifter, aa, akS
  /*
  - Sndfl can be any Sndfl which is supposed to work as a modulation
  source
  - kModFreq is the playback speed of the sndfl
  */
  aIn, kModFreq, Sndfl xin

  // mod source
  iChns filenchnls Sndfl 
  if iChns == 1 then
    iFt1 ftgen 0,0,0,1,Sndfl,0,0,0
    iFt2 = iFt1
  elseif iChns == 2 then
    iFt1 ftgen 0,0,0,1,Sndfl,0,0,1
    iFt2 ftgen 0,0,0,1,Sndfl,0,0,2
  endif

  iFlLen filelen Sndfl

  // modulation
  aSin, aCos hilbert aIn

  aPhsSin phasor kModFreq / iFlLen, 0
  aPhsCos phasor kModFreq / iFlLen, 0.25   
  aModSin table3 aPhsSin, iFt1, 1
  aModCos table3 aPhsCos, iFt1, 1
  aMod1 = aSin * aModCos
  aMod2 = aCos * aModSin
  aSum =  (aMod1 + aMod2) * (1.0 / sqrt(2.0))
  aDiff = (aMod1 - aMod2) * (1.0 / sqrt(2.0))

  xout aSum, aDiff
  ;; by PvN
endop

opcode bode_shifter, aa, aa
  /*
  - aModSource can be any audio input which is working as modulation
  source
  - kModFreq is freq shift in Hz
  */
  aIn, aModSource xin

  aSin, aCos hilbert aIn
  aModCos, aModSin hilbert aModSource
  aMod1 = aSin * aModCos
  aMod2 = aCos * aModSin
  aSum =  (aMod1 + aMod2) * (1.0 / sqrt(2.0))
  aDiff = (aMod1 - aMod2) * (1.0 / sqrt(2.0))

  xout aSum, aDiff
  ;; by PvN
endop
