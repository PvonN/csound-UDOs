;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sndfl_looper
;;; - loop segments from a soundfile with playback speed control
;;; (which alters the pitch), control of the loop start point, the
;;; size of the loop segment, a offset between two playheads to create
;;; a stereo effect and a predefined windowing function table
;;; - SFile -> path to soundfile
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
/* sndfl looping */
opcode sndfl_looper, aa, Skkkki
  SFile,kSpeed,kLoopStart,kLoopSize,kStereoOffset,iWndwFt xin
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
    ;; by philipp von neumann
endop