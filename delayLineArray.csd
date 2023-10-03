;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; recursive delay lines - adding-version
;;; creates recursive an array of delay-lines where the input signal
;;; is fed in parallel in an array of delay lines
;;; can create delay time offsets for each instance in samples
opcode delayLineArray, a, akkkip
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
    aDelOut += delayLineArray(aDelOut, kDelTime+kOffset, kDelOffset,
    kFdbk, iDelBuf, iInstances-1)
  endif
  ;; output limiting
  aDelOut limit aDelOut, -1, 1
  ;; output
  xout aDelOut
  ;;; UDO by philipp neumann
endop

