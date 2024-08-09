;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sndfl_looper2_ambi !needs the ambi_encode UDO!
;;; - loop segments from a soundfile with playback speed control
;;; (which alters the pitch), control of the loop start point, the
;;; size of the loop segment, a offset between two playheads to create
;;; a stereo effect and a predefined windowing function table
;;; - sndfl_looper2_ambi puts out an encoded ambisonics audio array up
;;; to 8th order; every loop segment is having a fixed position
;;; defined by kAzi and kAlti
;;; - sndfl_looper2_ambi allows for individual segment masking to create
;;; rhythmic effects
;;; - SInFile -> path to soundfile
;;; - kSpeed -> factor for playback speed -> 1 = original speed, 2 =
;;; double speed, 0.5 = half speed, -1 = original speed but backwards
;;; - kLoopStart -> position of the loop playback (between 0 and 1)
;;; while 0 start of the file and 1 = end of the file
;;; - kLoopSize -> size of the loop segment as a factor (usually a value between
;;; 0.0001 and 1; 1 = the whole sound (factor*length of the soundfile)
;;; - kStereoOffset -> creates a offset between two playheads; a value
;;; between 0 and 1; when this value is changed, the instrument is
;;; reninitalisated, so be carefull with changing this parameter
;;; during playback, could resolve in clicks
;;; - kAzi -> Azimuth value as degree value of a circle (0 - 360)
;;; - kAlti -> Altitude / elevation value as degree value of a circle (0 - 360)
;;; - kMaskArr -> masking of the individual events; for example to create
;;; rhythmic patterns
;;; - iOrder -> order of the ambisonics encoding -> up to 8th order;
;;; defines the size of the output array
opcode sndfl_looper2_ambi,a[],Skkkkikkk[]i
  ;; inputs
  SInFile,kSpeed,kLoopStart,kLoopSize,kStereoOffset,iWndwFt,kAzi,kAlti,kMaskArr[],iOrder xin
  iAmbiChn = (iOrder+1)^2
  
  ;; read data from soundfil
  iSndflSec filelen SInFile
  iSndflSr filesr SInFile
  iSndflSamps = iSndflSec*iSndflSr
  
  ;; create the table for the soundfile
  iSndflNumChnls filenchnls SInFile
  if iSndflNumChnls == 1 then
    iSndflTbl1 ftgen 0,0,0,1,SInFile,0,0,1
    iSndflTbl2 = iSndflTbl1 
  elseif iSndflNumChnls == 2 then
    iSndflTbl1 ftgen 0,0,0,1,SInFile,0,0,1
    iSndflTbl2 ftgen 0,0,0,1,SInFile,0,0,2
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

    aWin1 table aIndex1,iWndwFt,1
    aWin2 table aIndex2,iWndwFt,1

    kArrCount1 = (k(aSyncOut1) == 1 ? kArrCount1+1 : kArrCount1)
    kArrCount1 = kArrCount1 % iAmbiChn
    kArrCount2 = (k(aSyncOut2) == 1 ? kArrCount2+1 : kArrCount2)
    kArrCount2 = kArrCount2 % iAmbiChn
    aSig1 table3 (aIndex1*kSize1)+kStart1,iSndflTbl1,0,0,1
    aSig2 table3 (aIndex2*kSize2)+kStart2,iSndflTbl2,0,0,1
    
    aSig1 *= aWin1
    aSig2 *= aWin2    
    
    ;; masking
    kMaskArr1[],kMaskArr2[] deinterleave kMaskArr
    kMaskCount1 init 0
    kMaskCount2 init 0
    kMaskCount1 = (k(aSyncOut1) == 1 ? kMaskCount1+1 : kMaskCount1)
    kMaskCount1 = kMaskCount1 % lenarray:i(kMaskArr1)
    kMaskCount2 = (k(aSyncOut2) == 1 ? kMaskCount2+1 : kMaskCount2)
    kMaskCount2 = kMaskCount2 % lenarray:i(kMaskArr2)
    aSig1 *= kMaskArr1[kMaskCount1]
    aSig2 *= kMaskArr2[kMaskCount2]

    ;; spatialization
    aEncArr1[] init iAmbiChn
    aEncArr2[] init iAmbiChn
    aEncArr1 ambi_encode aSig1,iOrder,kAzi,kAlti
    aEncArr2 ambi_encode aSig2,iOrder,kAzi,kAlti

    ;; sum arrays
    aOutArr[] init iAmbiChn
    trim aOutArr,iAmbiChn
    aOutArr[0] sum aEncArr1[0]/2,aEncArr2[0]/2
    aOutArr[1] sum aEncArr1[1]/2,aEncArr2[1]/2
    aOutArr[2] sum aEncArr1[2]/2,aEncArr2[2]/2
    aOutArr[3] sum aEncArr1[3]/2,aEncArr2[3]/2

      if iOrder < 2 goto end
      aOutArr[4] sum aEncArr1[4]/2,aEncArr2[4]/2
      aOutArr[5] sum aEncArr1[5]/2,aEncArr2[5]/2
      aOutArr[6] sum aEncArr1[6]/2,aEncArr2[6]/2
      aOutArr[7] sum aEncArr1[7]/2,aEncArr2[7]/2
      aOutArr[8] sum aEncArr1[8]/2,aEncArr2[8]/2
      
        if iOrder < 3 goto end
	aOutArr[9] sum aEncArr1[9]/2,aEncArr2[9]/2
	aOutArr[10] sum aEncArr1[10]/2,aEncArr2[10]/2
	aOutArr[11] sum aEncArr1[11]/2,aEncArr2[11]/2
	aOutArr[12] sum aEncArr1[12]/2,aEncArr2[12]/2
	aOutArr[13] sum aEncArr1[13]/2,aEncArr2[13]/2
	aOutArr[14] sum aEncArr1[14]/2,aEncArr2[14]/2
	aOutArr[15] sum aEncArr1[15]/2,aEncArr2[15]/2

	  if iOrder < 4 goto end
	  aOutArr[16] sum aEncArr1[16]/2,aEncArr2[16]/2
	  aOutArr[17] sum aEncArr1[17]/2,aEncArr2[17]/2
	  aOutArr[18] sum aEncArr1[18]/2,aEncArr2[18]/2
	  aOutArr[19] sum aEncArr1[19]/2,aEncArr2[19]/2
	  aOutArr[20] sum aEncArr1[20]/2,aEncArr2[20]/2
	  aOutArr[21] sum aEncArr1[21]/2,aEncArr2[21]/2
	  aOutArr[22] sum aEncArr1[22]/2,aEncArr2[22]/2
	  aOutArr[23] sum aEncArr1[23]/2,aEncArr2[23]/2
	  aOutArr[24] sum aEncArr1[24]/2,aEncArr2[24]/2

	    if iOrder < 5 goto end
	    aOutArr[25] sum aEncArr1[25]/2,aEncArr2[25]/2
	    aOutArr[26] sum aEncArr1[26]/2,aEncArr2[26]/2
	    aOutArr[27] sum aEncArr1[27]/2,aEncArr2[27]/2
	    aOutArr[28] sum aEncArr1[28]/2,aEncArr2[28]/2
	    aOutArr[29] sum aEncArr1[29]/2,aEncArr2[29]/2
	    aOutArr[30] sum aEncArr1[30]/2,aEncArr2[30]/2
	    aOutArr[31] sum aEncArr1[31]/2,aEncArr2[31]/2
	    aOutArr[32] sum aEncArr1[32]/2,aEncArr2[32]/2
	    aOutArr[33] sum aEncArr1[33]/2,aEncArr2[33]/2
	    aOutArr[34] sum aEncArr1[34]/2,aEncArr2[34]/2
	    aOutArr[35] sum aEncArr1[35]/2,aEncArr2[35]/2

	      if iOrder < 6 goto end
	      aOutArr[36] sum aEncArr1[36]/2,aEncArr2[36]/2
	      aOutArr[37] sum aEncArr1[37]/2,aEncArr2[37]/2
	      aOutArr[38] sum aEncArr1[38]/2,aEncArr2[38]/2
	      aOutArr[39] sum aEncArr1[39]/2,aEncArr2[39]/2
	      aOutArr[40] sum aEncArr1[40]/2,aEncArr2[40]/2
	      aOutArr[41] sum aEncArr1[41]/2,aEncArr2[41]/2
	      aOutArr[42] sum aEncArr1[42]/2,aEncArr2[42]/2
	      aOutArr[43] sum aEncArr1[43]/2,aEncArr2[43]/2
	      aOutArr[44] sum aEncArr1[44]/2,aEncArr2[44]/2
	      aOutArr[45] sum aEncArr1[45]/2,aEncArr2[45]/2
	      aOutArr[46] sum aEncArr1[46]/2,aEncArr2[46]/2
	      aOutArr[47] sum aEncArr1[47]/2,aEncArr2[47]/2
	      aOutArr[48] sum aEncArr1[48]/2,aEncArr2[48]/2

	        if iOrder < 7 goto end
		aOutArr[49] sum aEncArr1[49]/2,aEncArr2[49]/2
		aOutArr[50] sum aEncArr1[50]/2,aEncArr2[50]/2
		aOutArr[51] sum aEncArr1[51]/2,aEncArr2[51]/2
		aOutArr[52] sum aEncArr1[52]/2,aEncArr2[52]/2
		aOutArr[53] sum aEncArr1[53]/2,aEncArr2[53]/2
		aOutArr[54] sum aEncArr1[54]/2,aEncArr2[54]/2
		aOutArr[55] sum aEncArr1[55]/2,aEncArr2[55]/2
		aOutArr[56] sum aEncArr1[56]/2,aEncArr2[56]/2
		aOutArr[57] sum aEncArr1[57]/2,aEncArr2[57]/2
		aOutArr[58] sum aEncArr1[58]/2,aEncArr2[58]/2
		aOutArr[59] sum aEncArr1[59]/2,aEncArr2[59]/2
		aOutArr[60] sum aEncArr1[60]/2,aEncArr2[60]/2
		aOutArr[61] sum aEncArr1[61]/2,aEncArr2[61]/2
		aOutArr[62] sum aEncArr1[62]/2,aEncArr2[62]/2
		aOutArr[63] sum aEncArr1[63]/2,aEncArr2[63]/2

		  if iOrder < 8 goto end
		  aOutArr[64] sum aEncArr1[64]/2,aEncArr2[64]/2
		  aOutArr[65] sum aEncArr1[65]/2,aEncArr2[65]/2
		  aOutArr[66] sum aEncArr1[66]/2,aEncArr2[66]/2
		  aOutArr[67] sum aEncArr1[67]/2,aEncArr2[67]/2
		  aOutArr[68] sum aEncArr1[68]/2,aEncArr2[68]/2
		  aOutArr[69] sum aEncArr1[69]/2,aEncArr2[69]/2
		  aOutArr[70] sum aEncArr1[70]/2,aEncArr2[70]/2
		  aOutArr[71] sum aEncArr1[71]/2,aEncArr2[71]/2
		  aOutArr[72] sum aEncArr1[72]/2,aEncArr2[72]/2
		  aOutArr[73] sum aEncArr1[73]/2,aEncArr2[73]/2
		  aOutArr[74] sum aEncArr1[74]/2,aEncArr2[74]/2
		  aOutArr[75] sum aEncArr1[75]/2,aEncArr2[75]/2
		  aOutArr[76] sum aEncArr1[76]/2,aEncArr2[76]/2
		  aOutArr[77] sum aEncArr1[77]/2,aEncArr2[77]/2
		  aOutArr[78] sum aEncArr1[78]/2,aEncArr2[78]/2
		  aOutArr[79] sum aEncArr1[79]/2,aEncArr2[79]/2
		  aOutArr[80] sum aEncArr1[80]/2,aEncArr2[80]/2
		  
		end:
		  
		  ;; output
		  xout aOutArr
;; by philipp von neumann
endop


