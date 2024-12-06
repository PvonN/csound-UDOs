/* ft_looper_stereo
function table looper with two voices, optional phasedistortion of
the readhead and masking table for both voices
- kSpeed -> transposition factor
- kLoopStart -> 0-1, Position in Soundfile
- kLoopSize -> size of loopsegment in MS
- iStereoOffset -> 0-1, offset of the both voices
- iWndwFt -> window function for 
- iPhaseDistTable -> FT for the phasedistortion
- kMaskArr[] -> masking array for voices
*/

// split a stereo ft into two mono ft
opcode split_ft, ii, i
  iFt xin

  iFtSr = ftsr(iFt)
  iFtLen = ftlen(iFt)
  iLenHalf = iFtLen/2
  iFt1 ftgen 0, 0, iLenHalf, 2, 0
  iFt2 ftgen 0, 0, iLenHalf, 2, 0
  ftslicei iFt, iFt1, 0, 0, 2
  ftslicei iFt, iFt2, 1, 0, 2

  xout iFt1, iFt2
endop

opcode ft_looper_stereo, aa, ikkkiiik[]
  setksmps 1
  iFt, kSpeed, kLoopStart, kLoopSize, iStereoOffset, iWndwFt, iPhaseDistTable, kMaskArr[] xin

  // read data from table
  if ftchnls(iFt) == 2 then
    iFt1, iFt2 split_ft iFt
  else
    iFt1 = iFt
    iFt2 = iFt
  endif

  iSndflTbl1 = iFt1
  iSndflTbl2 = iFt2

  // calculate size
  iSndflSamps = ftlen(iFt1)
  iSndflSr = ftsr(iFt)
  iSndflSeconds = iSndflSamps / iSndflSr
  iSndflMs = iSndflSeconds * 1000 ;; size of ft in MS
  kSize = ((kLoopSize / 1000) * iSndflSr) ;; loop size in samples

  // main phasor
  kSizeFactor = kSize / iSndflSamps
  kPhasorSpeed = (kSpeed / iSndflSeconds)
  kPhasorSpeed = kPhasorSpeed / kSizeFactor

  aSyncOut1 init 1
  aSyncOut2 init 1
  kPhasorSpeed1 = (k(aSyncOut1) == 1 ? kPhasorSpeed : kPhasorSpeed1)
  kPhasorSpeed2 = (k(aSyncOut2) == 1 ? kPhasorSpeed : kPhasorSpeed2)
  iOff1 = iStereoOffset
  aSyncIn init 0
  aMainPhasor1,aSyncOut1 syncphasor kPhasorSpeed1,aSyncIn
  aMainPhasor2,aSyncOut2 syncphasor kPhasorSpeed2,aSyncIn,iOff1

  // phase distortion
  aPhaseDst1 tablei aMainPhasor1, iPhaseDistTable, 1
  aPhaseDst2 tablei aMainPhasor2, iPhaseDistTable, 1

  // soundfile table
  kStart = kLoopStart * iSndflSamps
  kSize1 = (k(aSyncOut1) == 1 ? kSize : kSize1)
  kSize2 = (k(aSyncOut2) == 1 ? kSize : kSize2)
  kStart1 = (k(aSyncOut1) == 1 ? kStart : kStart1)
  kStart2 = (k(aSyncOut2) == 1 ? kStart : kStart2)
  aSndfl1 table3 (aPhaseDst1 * kSize1)+kStart1,iSndflTbl1,0,0,1
  aSndfl2 table3 (aPhaseDst2 * kSize2)+kStart2,iSndflTbl2,0,0,1

  // window table
  aWin1 table3 aMainPhasor1,iWndwFt,1
  aWin2 table3 aMainPhasor2,iWndwFt,1
  aOut1 = aWin1*aSndfl1
  aOut2 = aWin2*aSndfl2

  // masking
  kMaskArr1[],kMaskArr2[] deinterleave kMaskArr
  kMaskCount1 init 0
  kMaskCount2 init 0
  kMaskCount1 = (k(aSyncOut1) == 1 ? kMaskCount1+1 : kMaskCount1)
  kMaskCount1 = kMaskCount1 % lenarray:i(kMaskArr1)
  kMaskCount2 = (k(aSyncOut2) == 1 ? kMaskCount2+1 : kMaskCount2)
  kMaskCount2 = kMaskCount2 % lenarray:i(kMaskArr2)
  aOut1 = aOut1*kMaskArr1[kMaskCount1]
  aOut2 = aOut2*kMaskArr2[kMaskCount2]

  ;; output
  xout aOut1, aOut2
  ;; by philipp von neumann
endop

