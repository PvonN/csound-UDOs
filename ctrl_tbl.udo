;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ctrl_tbl
;;; - allows indexing the numeric data from a text file with optional
;;; interpolation between values
;;; - aIndex -> any indexing input e.g. a phasor (0 - 1)
;;; - SFile -> path to .txt file with the numeric data (uses GEN23,
;;; see csound manual for information for this)
;;; - iInterp -> interpolation mode; 0 = no interpolation, 1 = linear
;;; interpolation, 3 = cubic interpolation
;;; - aOut -> indexed data
opcode ctrl_tbl,a,aSo
  ;; input
  aIndex,SFile,iInterp xin 

  ;; create table from file
  iTable ftgen 0,0,0,-23,SFile

  ;; read the table
  if iInterp == 1 then
    aCtrl tablei aIndex,iTable,1
  elseif iInterp == 0 then
    aCtrl table aIndex,iTable,1
  elseif iInterp == 3 then
    aCtrl table3 aIndex,iTable,1
  endif
  
  ;; output
  xout aCtrl
;; by philipp von neumann
endop

