;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; instruments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; allows flexible wrap around looping of a soundfile
opcode sndfl_looper, aa, Skkkki
  SFile, kSpeed, kLoopStart, kLoopSize, kStereoOffset, iWndwFt xin
  setksmps 1
  ;; read data from soundfil
  iSndflSec filelen SFile
  iSndflSr filesr SFile
  iSndflSamps = iSndflSec*iSndflSr
  
  ;; create the tables for the soundfile
  iSndflNumChnls filenchnls SFile
  if iSndflNumChnls == 1 then
    iSndflTbl1 ftgen 0,0,0,1,SFile,0,0,1
    iSndflTbl2 = iSndflTbl1 
  elseif iSndflNumChnls == 2 then
    iSndflTbl1 ftgen 0,0,0,1,SFile,0,0,1
    iSndflTbl2 ftgen 0,0,0,1,SFile,0,0,2
  endif

  ;; parameter for the table reading
  kChange changed kStereoOffset
  if kChange == 1 then
    reinit UPDATE
  endif

  kSpeed = kSpeed
  kStart = (kLoopStart*iSndflSamps)
  kSize = kLoopSize*iSndflSamps
  kPhasorSpeed = kSpeed/(kSize/iSndflSr)
  aSyncIn init 0
  aSyncOut1 init 1
  aSyncOut2 init 1
  kPhasorSpeed1 = (k(aSyncOut1) == 1 ? kPhasorSpeed : kPhasorSpeed1)
  kPhasorSpeed2 = (k(aSyncOut2) == 1 ? kPhasorSpeed : kPhasorSpeed2)

  UPDATE:
    aIndex1,aSyncOut1 syncphasor kPhasorSpeed1,aSyncIn
    aIndex2,aSyncOut2 syncphasor kPhasorSpeed2,aSyncIn,i(kStereoOffset)
    kSize1 = (k(aSyncOut1) == 1 ? kSize : kSize1)
    kSize2 = (k(aSyncOut2) == 1 ? kSize : kSize2)
    kStart1 = (k(aSyncOut1) == 1 ? kStart : kStart1)
    kStart2 = (k(aSyncOut2) == 1 ? kStart : kStart2)
    aSndfl1 table3 (aIndex1*kSize1)+kStart1,iSndflTbl1,0,0,1
    aSndfl2 table3 (aIndex2*kSize2)+kStart2,iSndflTbl2,0,0,1
    aWin1 table3 aIndex1,iWndwFt,1
    aWin2 table3 aIndex2,iWndwFt,1

    ;; output
    aSndfl1 *= aWin1
    aSndfl2 *= aWin2
    xout aSndfl1,aSndfl2 
endop

opcode ft_looper, aa, iikkkki
  iFt1, iFt2, kSpeed, kLoopStart, kLoopSize, kStereoOffset, iWndwFt xin
  setksmps 1
  ;; read data from the ft
  iTableSizeSmps1 = ftlen(iFt1)    ; samples
  iTableSizeSecs1 = ftlen(iFt1)*sr ; seconds
  iTableSizeSmps2 = ftlen(iFt2)    ; samples
  iTableSizeSecs2 = ftlen(iFt2)*sr ; seconds

  ;; parameter for the table reading
  kChange changed kStereoOffset
  if kChange == 1 then
    reinit UPDATE
  endif

  kSpeed = kSpeed
  kStart = (kLoopStart*iTableSizeSmps1)
  kSize = kLoopSize*iTableSizeSmps1
  kPhasorSpeed = kSpeed/(kSize/sr)
  aSyncIn init 0
  aSyncOut1 init 1
  aSyncOut2 init 1
  kPhasorSpeed1 = (k(aSyncOut1) == 1 ? kPhasorSpeed : kPhasorSpeed1)
  kPhasorSpeed2 = (k(aSyncOut2) == 1 ? kPhasorSpeed : kPhasorSpeed2)

  UPDATE:
    aIndex1,aSyncOut1 syncphasor kPhasorSpeed1,aSyncIn
    aIndex2,aSyncOut2 syncphasor kPhasorSpeed2,aSyncIn,i(kStereoOffset)
    kSize1 = (k(aSyncOut1) == 1 ? kSize : kSize1)
    kSize2 = (k(aSyncOut2) == 1 ? kSize : kSize2)
    kStart1 = (k(aSyncOut1) == 1 ? kStart : kStart1)
    kStart2 = (k(aSyncOut2) == 1 ? kStart : kStart2)
    aSndfl1 table3 (aIndex1*kSize1)+kStart1,iFt1,0,0,1
    aSndfl2 table3 (aIndex2*kSize2)+kStart2,iFt2,0,0,1
    aWin1 table3 aIndex1,iWndwFt,1
    aWin2 table3 aIndex2,iWndwFt,1

    ;; output
    aSndfl1 *= aWin1
    aSndfl2 *= aWin2
    xout aSndfl1,aSndfl2 
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
opcode ctrl_arr,a,ki[]oo
  ;; iNormOutput default 0 -> no normalization of output
  ;; iInterp default 0 -> no interpolation between array values
  ;; reads an array as input and outputs control signals with the
  ;; option to normalize the output.
  ;; the array is copied into a table to be used with tablei and read
  ;; out with a phasor.
  ;; to prevent clicks when used with amplitude values use 'port' on
  ;; the output
  ;; to prevent value jumps end the input array with the first value
  ;; of the array
  
  ;; input
  kSpeed,iArr[],iNormOutput,iInterp xin 

  ;; create table from array
  if iNormOutput == 1 then
    scalearray iArr,0,1
  endif
  
  iTable ftgen 0,0,-lenarray:i(iArr),2,0
  copya2ftab iArr,iTable

  ;; read the table
  aIndex phasor kSpeed
  if iInterp == 1 then
    iLimit = 1-1/(lenarray(iArr))
    aCtrl tablei aIndex*iLimit,iTable,1
  elseif iInterp == 0 then
    aCtrl table aIndex,iTable,1
  endif
  
  ;; output
  xout aCtrl
endop


opcode ctrl_arr,a,kk[]oo
  ;; iNormOutput default 0 -> no normalization of output
  ;; iInterp default 0 -> no interpolation between array values
  ;; reads an array as input and outputs control signals with the
  ;; option to normalize the output.
  ;; the array is copied into a table to be used with tablei and read
  ;; out with a phasor.
  ;; to prevent clicks when used with amplitude values use 'port' on
  ;; the output
  ;; to prevent value jumps end the input array with the first value
  ;; of the array
  
  ;; input
  kSpeed,kArr[],iNormOutput,iInterp xin 

  ;; create table from array
  if iNormOutput == 1 then
    scalearray kArr,0,1
  endif
  
  iTable ftgen 0,0,-lenarray:i(kArr),2,0
  copya2ftab kArr,iTable

  ;; read the table
  aIndex phasor kSpeed
  if iInterp == 1 then
    iLimit = 1-1/(lenarray(kArr))
    aCtrl tablei aIndex*iLimit,iTable,1
  elseif iInterp == 0 then
    aCtrl table aIndex,iTable,1
  endif
  
  ;; output
  xout aCtrl
endop

opcode key_pressed, k, kki
  ;; output a trigger signal (1) when a defined key is pressed  
  kKey, kDown, iAscii xin
  kPrev init 0 ;previous key value
  kOut = (kKey == iAscii || (kKey == -1 && kPrev == iAscii) ? 1 : 0)
  kPrev = (kKey > 0 ? kKey : kPrev)
  kPrev = (kPrev == kKey && kDown == 0 ? 0 : kPrev)
  xout kOut
endop


opcode rndInt, i, ii
  ;; random integer  between iStart and iEnd (included)
  iStart, iEnd xin
  iRnd random iStart, iEnd+.999
  iRndInt = int(iRnd)
  xout iRndInt
endop


opcode linRnd_low, i, ii
  ;; linear random with precedence of lower values
  iMin, iMax xin
;generate two random values with the random opcode
  iOne       random     iMin, iMax
  iTwo       random     iMin, iMax
  ;compare and get the lower one
  iRnd       =          iOne < iTwo ? iOne : iTwo
  xout       iRnd
endop


opcode linRnd_high, i, ii
  ;; linear random with precedence of higher values
  iMin, iMax xin
;generate two random values with the random opcode
  iOne       random     iMin, iMax
  iTwo       random     iMin, iMax
  ;compare and get the higher one
  iRnd       =          iOne > iTwo ? iOne : iTwo
  xout       iRnd
endop

opcode linRnd_low, k, kk
  ;linear random with precedence of lower values
  kMin, kMax xin
;generate two random values with the random opcode
  kOne       random     kMin, kMax
  kTwo       random     kMin, kMax
  ;compare and get the lower one
  kRnd       =          kOne < kTwo ? kOne : kTwo
  xout       kRnd
endop

opcode linRnd_high, k, kk
  ;linear random with precedence of higher values
  kMin, kMax xin
;generate two random values with the random opcode
  kOne       random     kMin, kMax
  kTwo       random     kMin, kMax
  ;compare and get the higher one
  kRnd       =          kOne > kTwo ? kOne : kTwo
  xout       kRnd
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PVS-Opcodes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
opcode flToPvsBuf, iik, kSooop
  ;; writes a soundfile to a pvs-buffer / f-buffer when triggered
  ; schreibt einen Soundfile in einen FFT-Buffer wenn der Trigger == 1 ist
  kTrig, SFile, iFFTsize, iOverlap, iWinSize, iWinShape xin
  setksmps 1
  ; default Werte 
  ; ausgelegt für eine SR von 44.1kHz
  iFFTsize = (iFFTsize == 0 ? 1024 : iFFTsize)
  iOverlap = (iOverlap == 0 ? 256 : iOverlap)
  iWinSize = (iWinSize == 0 ? iFFTsize : iWinSize)
  ; wenn der Trigger == 1 ist führe den Loop aus und
  ; schreibe das Soundfile in den Buffer
  if kTrig == 1 then
    ; Länge des Soundfiles in Sekunden
    iLen filelen SFile
    ; benötigte kCycle um das Soundfile in den Buffer zu schreiben
    kNumCycles = iLen*kr 
    kCycle init 0
    iNumChnls filenchnls SFile
    while   kCycle < kNumCycles do
      if iNumChnls == 2 then
	aIn1, aIn2 soundin SFile
	aIn sum aIn1, aIn2
      elseif iNumChnls == 1 then
	aIn soundin SFile
      endif
      fftin pvsanal aIn, iFFTsize, iOverlap, iWinSize, iWinShape
      ; um das komplette Soundfile in den Buffer einzuschreiben ist es notwendig
      ; das Delay der Analyse zu berücksichtigen und es der Länge des Buffers
      ; hinzuzufügen
      ; (iFFTsize/sr) entspricht dem Delay der Analyse
      iBuf, kTim pvsbuffer fftin, iLen+(iFFTsize/sr) 
      kCycle += 1
    od
  endif

  xout iBuf, iLen, kTim
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Array Opcodes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; erzeugt eine Permutation aus einen gegebenen Array
opcode arrShuffle, i[], i[]
  iInArr[] xin
  iLen = lenarray(iInArr)
  iOutArr[] init iLen
  iIndx = 0
  iEnd = iLen-1
  while iIndx < iLen do
    ;get one random element and put it in iOutArr
    iRndIndx rndInt 0, iEnd
    iOutArr[iIndx] = iInArr[iRndIndx]
    ;shift the elements after this one to the left
    while iRndIndx < iEnd do
      iInArr[iRndIndx] = iInArr[iRndIndx+1]
      iRndIndx += 1
    od
    ;reset end and increase counter
    iIndx += 1
    iEnd -= 1
  od
  xout iOutArr
endop

; erzeugt einen Array für Startzeiten resultierenden aus einen
; Array welcher Aufrufdauern für ein Instrument beinhaltet
opcode StartTimeFromDuration_Array, i[], i[]
  ; creates an array for starttimes from a array with holds durations
  ; for instrumentcalls 
  ; to work together with instrument trigger opcodes like 'event'
  ; See 'Funktionslust-Hauptsequenz'
  iDurArr[] xin 

  iStartTimeArr[] init lenarray(iDurArr)
  iDurIndex init 0
  iStartValue = 0
  iNewVal = iStartValue
  while iDurIndex < lenarray(iDurArr) do
    iStartTimeArr[iDurIndex] = iNewVal
    ;printk2 kNewVal
    iLastVal = iNewVal
    iNewVal = iLastVal + iDurArr[iDurIndex]
    iDurIndex += 1
  od 

  xout iStartTimeArr
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Synth Opcodes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

opcode AddSynth,a,i[]i[]iooo
  /* iFqs[], iAmps[]: arrays with frequency ratios and amplitude multipliers
    iBasFreq: base frequency (hz)
    iPtlIndex: partial index (first partial = index 0)
    iFreqDev, iAmpDev: maximum frequency (cent) and amplitude (db) deviation */
    iFqs[], iAmps[], iBasFreq, iPtlIndx, iFreqDev, iAmpDev xin
    iFreq = iBasFreq * iFqs[iPtlIndx] * cent(rnd31:i(iFreqDev,0))  ; cent(0) -> 1; entspricht einem Faktor
    iAmp = iAmps[iPtlIndx] * ampdb(rnd31:i(iAmpDev,0))             ; ampdb(0) -> 1
    aPartial poscil iAmp, iFreq
    if iPtlIndx < lenarray(iFqs)-1 then
      aPartial += AddSynth(iFqs,iAmps,iBasFreq,iPtlIndx+1,iFreqDev,iAmpDev)
    endif
    xout aPartial
    ;;; by Joachim Heintz
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; feedback-version
;;; creates recursive an array of delayl-line where one signal after the
;;; next is fed into the next delay line
;;; can create delay time offsets for each instance in samples
opcode recursiveFeedbackDelay, a, akkkip
  ;; kontrol-rate set on sample-rate
  setksmps 1
  ;; inputs: signal, delay-time, delay-time offset added to every
  ;; instance in samples, feedback ratio (use negative feedback ratios
  ;; for not creating DC-Offsets), delay buffer size, number of
  ;; instances
  aDelIn, kDelTime, kDelOffset, kFdbk, iDelBuf, iInstances xin
  ;; basics delay-line
  aDelDump delayr iDelBuf
  aDelTap deltap kDelTime
  delayw aDelIn + (aDelTap * kFdbk)
  ;; signal limiting
  aDelOut limit aDelTap, -1, 1
  ;; delay-time-offset in samples
  kOffset = kDelOffset/sr
  ;; recursion
  if iInstances > 1 then
    aDelOut = recursiveFeedbackDelay(aDelOut, kDelTime+kOffset, kDelOffset,
    kFdbk, iDelBuf, iInstances-1)
  endif
  ;; output limiting
  aDelOut limit aDelOut, -1, 1
  ;; output
  xout aDelOut
  ;;; UDO by philipp neumann
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; adding-version
;;; creates recursive an array of delayl-line where one signal after the
;;; next is fed into the next delay line
;;; can create delay time offsets for each instance in samples
opcode delayline_array, a, akkkip
  ;; kontrol-rate set on sample-rate
  setksmps 1
  ;; inputs: signal, delay-time, delay-time offset added to every
  ;; instance in samples, feedback ratio (use negative feedback ratios
  ;; for not creating DC-Offsets), delay buffer size, number of
  ;; instances
  aDelIn, kDelTime, kDelOffset, kFdbk, iDelBuf, iInstances xin
  ;; basics delay-line
  aDelDump delayr iDelBuf
  aDelTap deltap kDelTime
  delayw aDelIn + (aDelTap * kFdbk)
  ;; signal limiting
  aDelOut limit aDelTap, -1, 1
  ;; delay-time-offset in samples
  kOffset = kDelOffset/sr
  ;; recursion
  if iInstances > 1 then
    aDelOut += delayline_array(aDelOut, kDelTime+kOffset, kDelOffset,
    kFdbk, iDelBuf, iInstances-1)
  endif
  ;; output limiting
  aDelOut limit aDelOut, -1, 1
  ;; output
  xout aDelOut
  ;;; UDO by philipp neumann
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; filter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; fir - averaging filter
;;; with optional order setting (default to first order)
opcode fir, a, ap
  ;; signal input and setting the order  
  aIn, iOrder xin
  ;; set kr to sr
  setksmps 1
  ;; one-sample delay1
  aDelOut delay1 aIn
  ;; recursion for flexible order
  if iOrder > 1 then
    aDelOut += fir(aDelOut, iOrder-1)
  endif
  ;; setting levels
  aOut sum aDelOut*(.5/iOrder), aIn*(.5/iOrder)
  ;; output
  xout aOut
  ;;; by philipp neumann
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; iir
;;; with optional order setting (default to first order)
opcode iir, a, ap
  ;; signal input, setting the order of the filter
  aIn, iOrder xin
  ;; set kr to sr
  setksmps 1
  ;; delay
  aDUMP delayr 0.1
  aDel deltap 1/sr
  aIn += aDel*(.5/iOrder)
  delayw aIn
  ;; recursion for order
  if iOrder > 1 then
    aDel += iir(aDel, iOrder-1)
  endif
  ;; output
  aOut = aDel
  xout aOut
  ;;; by philipp neumann
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; transient tracking

opcode transient_tracking, k, ak
  ;; input signal which transients are tracked and the threshold value
  ;; for activating the output trigger
  aSignal, kThresh xin
  setksmps 1
  
  ;; iWait prevents multiple trigger in a very short time
  ;; value is in samples
  iWait  = 1000
  ;; initial timer is bigger then iWait, so a trigger can be generated immediatly
  kTimer init 1001
  ;; rms value of signal input
  kRms rms aSignal, 20
  ;; the differnce from the actual rms value and the rms value delayed by
  ;; iSampleTime is kChange
  ;; if kChange is bigger then kThresh kTrig == 1
  iSampleTime = 0.01
  kRmsPrev delayk  kRms, iSampleTime
  kChange  =       kRms - kRmsPrev
  
  if kTimer > iWait then
    kTrig = (kChange > kThresh ? 1 : 0)
    ;; reset safety timer when trigger == 1
    kTimer = (kTrig == 1 ? 0 : kTimer)
  else
    kTimer += ksmps
    kTrig = 0
  endif
  
  ;; output trigger
  xout kTrig
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; samples
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create a buffer for writing audio data inside
opcode create_buffer, i, i
  iLen xin
  iFt ftgen 0, 0, iLen*sr, 2, 0
  xout iFt
endop

;; record audio data to a buffer when a trigger is 1
opcode record_buffer, 0, aik
  aIn, iFt, kRecTrig  xin
  setksmps  1 
  kIndx init 0 
  if kRecTrig == 1 then
    tablew aIn, a(kIndx), iFt
    kIndx = (kIndx+1) % ftlen(iFt)
  endif
endop

;; play audio data from a buffer when a trigger is 1
opcode play_buffer, a, ik
  iFt, kPlayTrig  xin
  setksmps  1 
  kIndx init 0 
  if kPlayTrig == 1 then
    aRead table a(kIndx), iFt
    kIndx = (kIndx+1) % ftlen(iFt)
  endif
  xout aRead
endop

;; load a soundfile in a function table
opcode file_to_buffer, i, S
  SFile xin
  iFt ftgen 0, 0, 0, 1, SFile, 0, 0, 0
  xout iFt
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; audio effects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pitch & modulation
;; stereo enhancer; creates a lively stereo field
;; could introduce phasing issues
opcode stereo_enhancer, aa, aa
  aIn1, aIn2 xin
  ;; mono-bass
  aLP1 butterlp aIn1, randomi:k(80, 130, 1)
  aLP2 butterlp aIn2, randomi:k(80, 130, 1)
  aLP sum aLP1*.5, aLP2*.5
  aLP1, aLP2 pan2 aLP, 0.5

  ;; wide-highs
  aHP1 butterhp aIn1, randomi:k(1250, 1750, 1)
  aHP2 butterhp aIn2, randomi:k(1250, 1750, 1)
  aHPleft1, aHPright1 pan2 aHP1, randomi:k(0, 0.1, 3)
  aHPleft2, aHPright2 pan2 aHP2, randomi:k(0.9, 1, 3)
  aHPleft sum aHPleft1, aHPleft2
  aHPright sum aHPright1, aHPright2

  ;; mids
  aMids1 butterhp aIn1, randomi:k(120, 160, 1)
  aMids2 butterhp aIn2, randomi:k(120, 160, 1)
  aMids1 butterlp aMids1, randomi:k(1000, 1500, 1)
  aMids2 butterlp aMids2, randomi:k(1000, 1500, 1)
  aMidsLeft1, aMidsRight1 pan2 aMids1, randomi:k(0.25, 0.5, 3)
  aMidsLeft2, aMidsRight2 pan2 aMids2, randomi:k(0.5, 0.75, 3)
  aMidsLeft sum aMidsLeft1, aMidsLeft2
  aMidsRight sum aMidsRight1, aMidsRight2
  
  aOut1 sum aLP1, aHPleft, aMidsLeft
  aOut2 sum aLP2, aHPright, aMidsRight
  xout aOut1, aOut2 
endop