;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; transient_tracking
;;; - tracks transients of a input signal above a RMS threshold and
;;; outputs a trigger signal

opcode transient_tracking, k, ak
  aSignal, kThresh xin
  
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
