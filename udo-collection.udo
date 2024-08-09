;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; collection of all UDOs in this repo
;;; maybe it needs some reorderning when some UDOs depend of each
;;; other
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/* utilities */
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


/* ambisonics */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ambi_encode
;;; - encode a mono signal up to 8th order ambisonics
;;; - takes a mono signal and creates a audio-array in the size
;;; depending on iorder ((iorder+1)^2) as output
;;; - kaz = azimuth in degrees (0 - 360)
;;; - kel = eleveation in degrees (0 - 360)
;;; - render the file with 'fout' opcode in csound
opcode ambi_encode,a[],aikk		
  asnd,iorder,kaz,kel xin

  aOutArr[] init (iorder+1)^2

  kaz = $M_PI*kaz/180
  kel = $M_PI*kel/180

  kcos_el = cos(kel)
  ksin_el = sin(kel)
  kcos_az = cos(kaz)
  ksin_az = sin(kaz)

  aOutArr[0] = asnd							; W
  aOutArr[1] = kcos_el*ksin_az*asnd		; Y	 = Y(1,-1)
  aOutArr[2] = ksin_el*asnd				; Z	 = Y(1,0)
  aOutArr[3] = kcos_el*kcos_az*asnd		; X	 = Y(1,1)

  if		iorder < 2 goto	end

  i2	= sqrt(3)/2
  kcos_el_p2 = kcos_el*kcos_el
  ksin_el_p2 = ksin_el*ksin_el
  kcos_2az = cos(2*kaz)
  ksin_2az = sin(2*kaz)
  kcos_2el = cos(2*kel)
  ksin_2el = sin(2*kel)

  aOutArr[4] = i2*kcos_el_p2*ksin_2az*asnd	; V = Y(2,-2)
  aOutArr[5] = i2*ksin_2el*ksin_az*asnd		; S = Y(2,-1)
  aOutArr[6] = .5*(3*ksin_el_p2 - 1)*asnd		; R = Y(2,0)
  aOutArr[7] = i2*ksin_2el*kcos_az*asnd		; S = Y(2,1)
  aOutArr[8] = i2*kcos_el_p2*kcos_2az*asnd	; U = Y(2,2)

  if		iorder < 3 goto	end	

  i31 = sqrt(5/8)
  i32 = sqrt(15)/2
  i33 = sqrt(3/8)

  kcos_el_p3 = kcos_el*kcos_el_p2
  ksin_el_p3 = ksin_el*ksin_el_p2
  kcos_3az = cos(3*kaz)
  ksin_3az = sin(3*kaz)
  kcos_3el = cos(3*kel)
  ksin_3el = sin(3*kel)

  aOutArr[9] = i31*kcos_el_p3*ksin_3az*asnd					; Q = Y(3,-3)
  aOutArr[10] = i32*ksin_el*kcos_el_p2*ksin_2az*asnd		; O = Y(3,-2)
  aOutArr[11] = i33*kcos_el*(5*ksin_el_p2-1)*ksin_az*asnd	; M = Y(3,-1)
  aOutArr[12] = .5*ksin_el*(5*ksin_el_p2-3)*asnd		; K = Y(3,0)
  aOutArr[13] = i33*kcos_el*(5*ksin_el_p2-1)*kcos_az*asnd	; L = Y(3,1)
  aOutArr[14] = i32*ksin_el*kcos_el_p2*kcos_2az*asnd		; N = Y(3,2)
  aOutArr[15] = i31*kcos_el_p3*kcos_3az*asnd				; P = Y(3,3)

    if		iorder < 4 goto	end	

    ic41 = (1/8)*sqrt(35)
    ic42 =	(1/2)*sqrt(35/2)
    ic43 = sqrt(5)/4
    ic44 = sqrt(5/2)/4
    kcos_el_p4 = kcos_el*kcos_el_p3
    ksin_el_p4 = ksin_el*ksin_el_p3
    kcos_4az = cos(4*kaz)
    ksin_4az = sin(4*kaz)
    kcos_4el = cos(4*kel)
    ksin_4el = sin(4*kel)
    aOutArr[16] = ic41*kcos_el_p4*ksin_4az*asnd							; Y(4,-4)
    aOutArr[17] = ic42*ksin_el*kcos_el_p3*ksin_3az*asnd					; Y(4,-3)
    aOutArr[18] = ic43*(7.*ksin_el_p2 - 1.)*kcos_el_p2*ksin_2az*asnd	; Y(4,-2)
    aOutArr[19] = ic44*ksin_2el*(7.*ksin_el_p2 - 3.)*ksin_az*asnd		; Y(4,-1)
    aOutArr[20] = (1/8)*(35.*ksin_el_p4 - 30.*ksin_el_p2 + 3.)*asnd	; Y(4,0)
    aOutArr[21] = ic44*ksin_2el*(7.*ksin_el_p2 - 3.)*kcos_az*asnd		; Y(4,1)
    aOutArr[22] = ic43*(7.*ksin_el_p2 - 1.)*kcos_el_p2*kcos_2az*asnd	; Y(4,2)
    aOutArr[23] = ic42*ksin_el*kcos_el_p3*kcos_3az*asnd				; Y(4,3)
    aOutArr[24] = ic41*kcos_el_p4*kcos_4az*asnd							; Y(4,4)

      if		iorder < 5 goto	end	
      
      ic51 = (3/8)*sqrt(7/2)
      ic52 = (3/8)*sqrt(35)
      ic53 = (1/8)*sqrt(35/2)
      ic54 = sqrt(105)/4
      ic55 = sqrt(15)/8
      kcos_el_p5 = kcos_el*kcos_el_p4
      ksin_el_p5 = ksin_el*ksin_el_p4
      kcos_5az = cos(5*kaz)
      ksin_5az = sin(5*kaz)
      kcos_5el = cos(5*kel)
      ksin_5el = sin(5*kel)
      aOutArr[25] = ic51*kcos_el_p5*ksin_5az*asnd							; Y(5,-5)
      aOutArr[26] = ic52*ksin_el*kcos_el_p4*ksin_4az*asnd					; Y(5,-4)
      aOutArr[27] = ic53*(9*ksin_el_p2 - 1)*kcos_el_p3*ksin_3az*asnd					; Y(5,-3)
      aOutArr[28] = ic54*ksin_el*(3*ksin_el_p2 - 1)*kcos_el_p2*ksin_2az*asnd		; Y(5,-2)
      aOutArr[29] = ic55*(21*ksin_el_p4 - 14*ksin_el_p3 + 1)*kcos_el*ksin_az*asnd	; Y(5,-1)
      aOutArr[30] = (1/8)*(63*ksin_el_p5 - 70*ksin_el_p3 + 15*ksin_el)*asnd		; Y(5,0)
      aOutArr[31] = ic55*(21*ksin_el_p4 - 14*ksin_el_p3 + 1)*kcos_el*kcos_az*asnd	; Y(5,1)
      aOutArr[32] = ic54*ksin_el*(3*ksin_el_p2 - 1)*kcos_el_p2*kcos_2az*asnd	; Y(5,2)
      aOutArr[33] = ic53*(9*ksin_el_p2 - 1)*kcos_el_p3*kcos_3az*asnd				; Y(5,3)
      aOutArr[34] = ic52*ksin_el*kcos_el_p4*kcos_4az*asnd					; Y(5,4)	
      aOutArr[35] = ic51*kcos_el_p5*kcos_5az*asnd					; Y(5,5)

	if		iorder < 6 goto	end	
	
	ic61 = (1/16)*sqrt(231/2)
	ic62 = (3/8)*sqrt(77/2)
	ic63 = (3/16)*sqrt(7)
	ic64 = (1/8)*sqrt(105/2)
	ic65 = (1/16)*sqrt(105/2)
	ic66 = (1/16)*sqrt(21)
	kcos_el_p6 = kcos_el*kcos_el_p5
	ksin_el_p6 = ksin_el*ksin_el_p5
	kcos_6az = cos(6*kaz)
	ksin_6az = sin(6*kaz)
	kcos_6el = cos(6*kel)
	ksin_6el = sin(6*kel)
	aOutArr[36] = ic61*kcos_el_p6*ksin_6az*asnd
	aOutArr[37] = ic62*ksin_el*kcos_el_p5*ksin_5az*asnd
	aOutArr[38] = ic63*(11*ksin_el_p2 - 1)*kcos_el_p4*ksin_4az*asnd
	aOutArr[39] = ic64*ksin_el*(11*ksin_el_p2 - 3)*kcos_el_p3*ksin_3az*asnd
	aOutArr[40] = ic65*((33*ksin_el_p4) - 18*ksin_el_p2 + 1)*kcos_el_p2*ksin_2az*asnd
	aOutArr[41] = ic66*ksin_2el*(33*ksin_el_p4 - 30*ksin_el_p2 + 5)*ksin_az*asnd
	aOutArr[42] = (1/16)*(231*ksin_el_p6 - 315*ksin_el_p4 + 105*ksin_el_p2 - 5)*asnd
	aOutArr[43] = ic66*ksin_2el*(33*ksin_el_p4 - 30*ksin_el_p2 + 5)*kcos_az*asnd
	aOutArr[44] = ic65*((33*ksin_el_p4) - 18*ksin_el_p2 + 1)*kcos_el_p2*kcos_2az*asnd
	aOutArr[45] = ic64*ksin_el*(11*ksin_el_p2 - 3)*kcos_el_p3*kcos_3az*asnd
	aOutArr[46] = ic63*(11*ksin_el_p2 - 1)*kcos_el_p4*kcos_4az*asnd
	aOutArr[47] = ic62*ksin_el*kcos_el_p5*kcos_5az*asnd
	aOutArr[48] = ic61*kcos_el_p6*kcos_6az*asnd

	  if		iorder < 7 goto	end	
	  ic71 = (3/32)*sqrt(143/3)
	  ic72 = (3/16)*sqrt(101/3)
	  ic73 = (3/32)*sqrt(77/3)
	  ic74 = (3/16)*sqrt(77/3)
	  ic75 = (3/32)*sqrt(7/3)
	  ic76 = (3/16)*sqrt(7/6)
	  ic77 = (1/32)*sqrt(7)
	  kcos_el_p7 = kcos_el*kcos_el_p6
	  ksin_el_p7 = ksin_el*ksin_el_p6
	  kcos_7az = cos(7*kaz)
	  ksin_7az = sin(7*kaz)
	  kcos_7el = cos(7*kel)
	  ksin_7el = sin(7*kel)
	  aOutArr[49] = ic71*kcos_el_p7*ksin_7az*asnd
	  aOutArr[50] = ic72*ksin_el*kcos_el_p6*ksin_6az*asnd
	  aOutArr[51] = ic73*(13*ksin_el_p2 - 1)*kcos_el_p5*ksin_5az*asnd
	  aOutArr[52] = ic74*(13*ksin_el_p3 - 3*ksin_el)*kcos_el_p4*ksin_4az*asnd
	  aOutArr[53] = ic75*(143*ksin_el_p4 - 66*ksin_el_p2 + 3)*kcos_el_p3*ksin_3az*asnd
	  aOutArr[54] = ic76*(143*ksin_el_p5 - 110*ksin_el_p3 + 15*ksin_el)*kcos_el_p2*ksin_2az*asnd
	  aOutArr[55] = ic77*(429*ksin_el_p6 - 495*ksin_el_p4 + 135*ksin_el_p2 - 5)*kcos_el*ksin_az*asnd
	  aOutArr[56] = (1/16)*(429*ksin_el_p7 - 693*ksin_el_p5 + 315*ksin_el_p3 - 35*ksin_el)*asnd
	  aOutArr[57] = ic77*(429*ksin_el_p6 - 495*ksin_el_p4 + 135*ksin_el_p2 - 5)*kcos_el*kcos_az*asnd
	  aOutArr[58] = ic76*(143*ksin_el_p5 - 110*ksin_el_p3 + 15*ksin_el)*kcos_el_p2*kcos_2az*asnd
	  aOutArr[59] = ic75*(143*ksin_el_p4 - 66*ksin_el_p2 + 3)*kcos_el_p3*kcos_3az*asnd
	  aOutArr[60] = ic74*(13*ksin_el_p3 - 3*ksin_el)*kcos_el_p4*kcos_4az*asnd
	  aOutArr[61] = ic73*(13*ksin_el_p2 - 1)*kcos_el_p5*kcos_5az*asnd
	  aOutArr[62] = ic72*ksin_el*kcos_el_p6*kcos_6az*asnd
	  aOutArr[63] = ic71*kcos_el_p7*kcos_7az*asnd

	    if		iorder < 8 goto	end	
	    ic81 = (3/128)*sqrt(715)
	    ic82 = (3/32)*sqrt(715)
	    ic83 = (1/32)*sqrt(429/2)
	    ic84 = (3/32)*sqrt(1001) 
	    ic85 = (3/64)*sqrt(77)
	    ic86 = (1/32)*sqrt(1155)
	    ic87 = (3/32)*sqrt(35/2)
	    ic88 = (3/32)
	    kcos_el_p8 = kcos_el*kcos_el_p7
	    ksin_el_p8 = ksin_el*ksin_el_p7
	    kcos_8az = cos(8*kaz)
	    ksin_8az = sin(8*kaz)
	    kcos_8el = cos(8*kel)
	    ksin_8el = sin(8*kel)
	    aOutArr[64] = ic81*kcos_el_p8*ksin_8az*asnd
	    aOutArr[65] = ic82*ksin_el*kcos_el_p7*ksin_7az*asnd
	    aOutArr[66] = ic83*(15*ksin_el_p2 - 1)*kcos_el_p6*ksin_6az*asnd
	    aOutArr[67] = ic84*(5*ksin_el_p3 - ksin_el)*kcos_el_p5*ksin_5az*asnd
	    aOutArr[68] = ic85*(65*ksin_el_p4 - 26*ksin_el_p2 + 1)*kcos_el_p4*ksin_4az*asnd
	    aOutArr[69] = ic86*(39*ksin_el_p5 - 26*ksin_el_p3 + 3*ksin_el)*kcos_el_p3*ksin_3az*asnd
	    aOutArr[70] = ic87*(143*ksin_el_p6 - 143*ksin_el_p4 + 33*ksin_el_p2 - 1)*kcos_el_p2*ksin_2az*asnd
	    aOutArr[71] = ic88*(715*ksin_el_p7 - 1001*ksin_el_p5 + 385*ksin_el_p3 - 35*ksin_el)*kcos_el*ksin_az*asnd
	    aOutArr[72] = (1/128)*(6435*ksin_el_p8 - 12012*ksin_el_p6 + 6930*ksin_el_p4 - 1260*ksin_el_p2 + 35)*asnd
	    aOutArr[73] = ic88*(715*ksin_el_p7 - 1001*ksin_el_p5 + 385*ksin_el_p3 - 35*ksin_el)*kcos_el*kcos_az*asnd
	    aOutArr[74] = ic87*(143*ksin_el_p6 - 143*ksin_el_p4 + 33*ksin_el_p2 - 1)*kcos_el_p2*kcos_2az*asnd
	    aOutArr[75] = ic86*(39*ksin_el_p5 - 26*ksin_el_p3 + 3*ksin_el)*kcos_el_p3*kcos_3az*asnd
	    aOutArr[76] = ic85*(65*ksin_el_p4 - 26*ksin_el_p2 + 1)*kcos_el_p4*kcos_4az*asnd
	    aOutArr[77] = ic84*(5*ksin_el_p3 - ksin_el)*kcos_el_p5*kcos_5az*asnd
	    aOutArr[78] = ic83*(15*ksin_el_p2 - 1)*kcos_el_p6*kcos_6az*asnd
	    aOutArr[79] = ic82*ksin_el*kcos_el_p7*kcos_7az*asnd
	    aOutArr[80] = ic81*kcos_el_p8*kcos_8az*asnd

	  end:
	      
	      xout aOutArr

	      ; original by Martin Neukom
	      ; edit by Philipp Neumann

endop

/* synthesizer */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sine
;;; - creates sine wave and uses the sine function instead of a
;;; wavetable
;;; - kAmp -> output amplitude
;;; - kFreq -> base freq
opcode sine,a,kk
  kAmp,kFreq xin
  aSine = sin(phasor:a(kFreq)*2*$M_PI)
  aSine *= kAmp
  xout aSine
  ;; by philipp von neumann
endop


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
endop
;; by philipp von neumann
/* instruments */
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sndfl_looper2
;;; - loop segments from a soundfile with playback speed control
;;; (which alters the pitch), control of the loop start point, the
;;; size of the loop segment, a offset between two playheads to create
;;; a stereo effect and a predefined windowing function table
;;; - sndfl_looper2 allows for individual segment masking to create
;;; rhythmic effects
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
;;; - kMaskArr -> masking of the individual events; the array is
;;; deinterleaved into two arrays inside the UDO, one for each
;;; playbackhead; so take into account that when kStereoOffset is 0
;;; then you need to thinkg in value pairs for the masking, else you
;;; don't hear the masking how it is planned
/* sndfl looping with masking */
opcode sndfl_looper2, aa, Skkkkik[]
  SFile,kSpeed,kLoopStart,kLoopSize,kStereoOffset,iWndwFt,kMaskArr[] xin
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

    aSig1 = aWin1*aSndfl1
    aSig2 = aWin2*aSndfl2

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

    ;; output
    xout aSig1,aSig2
    ;; by philipp von neumann
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sndfl_looper_ambi !needs the ambi_encode UDO!
;;; - loop segments from a soundfile with playback speed control
;;; (which alters the pitch), control of the loop start point, the
;;; size of the loop segment, a offset between two playheads to create
;;; a stereo effect and a predefined windowing function table
;;; - sndfl_looper_ambi puts out an encoded ambisonics audio array up
;;; to 8th order; every loop segment is having a fixed position
;;; defined by kAzi and kAlti
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
;;; - kMask -> masking of the individual events; for example to create
;;; amplitude envelopes
;;; - iOrder -> order of the ambisonics encoding -> up to 8th order;
;;; defines the size of the output array
opcode sndfl_looper_ambi,a[],Skkkkikkki
  ;; inputs
  SInFile,kSpeed,kLoopStart,kLoopSize,kStereoOffset,iWndwFt,kAzi,kAlti,kMask,iOrder xin
  setksmps 1
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
    kMaskReal1 init i(kMask)
    kMaskReal2 init i(kMask)
    kMaskReal1 = (k(aSyncOut1) == 1 ? kMask : kMaskReal1)
    kMaskReal2 = (k(aSyncOut2) == 1 ? kMask : kMaskReal2)
    aSig1 *= kMaskReal1
    aSig2 *= kMaskReal2
    
    ;; spatialization
    aEncArr1[] init iAmbiChn
    aEncArr2[] init iAmbiChn
    kAziReal1 init i(kAzi)
    kAziReal2 init i(kAzi)
    kAltiReal1 init i(kAlti)
    kAltiReal2 init i(kAlti)
    kAziReal1 = (k(aSyncOut1) == 1 ? kAzi : kAziReal1)
    kAziReal2 = (k(aSyncOut2) == 1 ? kAzi : kAziReal2)
    kAltiReal1 = (k(aSyncOut1) == 1 ? kAlti : kAltiReal1)
    kAltiReal2 = (k(aSyncOut2) == 1 ? kAlti : kAltiReal2)
    aEncArr1 ambi_encode aSig1,iOrder,kAziReal1,kAltiReal1
    aEncArr2 ambi_encode aSig2,iOrder,kAziReal2,kAltiReal2

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

/* filter */
/* other */
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ambi_spectrum (!needs ambi_encode.udo!)
;;; - takes a mono signal as input and creates a lively spectrum in a
;;; ambisonics field; can be used for background ambience or making a
;;; pad sounding bigger; gives a encoded ambisonics file as a output array
;;; - splits the signal into 6 frenquncy bands and moves them in the
;;; ambisonics field
;;; - kMovement -> amount of movement (0-1)
;;; - kSpeed -> speed of movement (0-1)
;;; - iOrder -> order of ambisonic encoding
opcode ambi_spectrum,a[],akki
  aIn,kMovement,kSpeed,iOrder xin

  iAmbiChn = (iOrder+1)^2
  
  ; split signal
  kLowF1 = 90
  a1 butterlp aIn,kLowF1      ; -90

  kHighF2 = kLowF1*2^(-3/12)
  kLowF2 = kLowF1*2            ; 75 - 180
  aHP2 butterhp aIn,kHighF2
  a2 butterlp aHP2,kLowF2

  kHighF3 = kLowF2*2^(-3/12)
  kLowF3 = kLowF2*3            ; 151 - 540
  aHP3 butterhp aIn,kHighF3
  a3 butterlp aHP3,kLowF3

  kHighF4 = kLowF3*2^(-3/12)
  kLowF4 = kLowF3*2           ; 454 - 1080
  aHP4 butterhp aIn,kHighF4
  a4 butterlp aHP4,kLowF4

  kHighF5 = kLowF4*2^(-3/12)
  kLowF5 = kLowF4*2           ; 908 - 2160
  aHP5 butterhp aIn,kHighF5
  a5 butterlp aHP5,kLowF5

  kHighF6 = kLowF5*2^(-3/12)
  a6 butterhp aIn,kHighF6

  
  ;; ambi encoding
  aEncArr1[] init iAmbiChn
  aEncArr2[] init iAmbiChn
  aEncArr3[] init iAmbiChn
  aEncArr4[] init iAmbiChn
  aEncArr5[] init iAmbiChn
  aEncArr6[] init iAmbiChn

  kMovement1 = kMovement/6
  kSpeed1 = kSpeed/6
  kAzi1 oscil kMovement1*360,kSpeed1*10
  kAlti1 = 0
  kMovement2 = kMovement/5
  kSpeed2 = kSpeed/5
  kAzi2 oscil kMovement2*360,kSpeed2*10
  kAlti2 = 18
  kMovement3 = kMovement/4
  kSpeed3 = kSpeed/4
  kAzi3 oscil kMovement3*360,kSpeed3*10
  kAlti3 = 36
  kMovement4 = kMovement/3
  kSpeed4 = kSpeed/3
  kAzi4 oscil kMovement4*360,kSpeed4*10
  kAlti4 = 54
  kMovement5 = kMovement/2
  kSpeed5 = kSpeed/2
  kAzi5 oscil kMovement5*360,kSpeed5*10
  kAlti5 = 72
  kMovement6 = kMovement
  kSpeed6 = kSpeed
  kAzi6 oscil kMovement6*360,kSpeed6*10
  kAlti6 = 90
  
  aEncArr1 ambi_encode a1,iOrder,kAzi1,kAlti1
  aEncArr2 ambi_encode a2,iOrder,kAzi2,kAlti2
  aEncArr3 ambi_encode a3,iOrder,kAzi3,kAlti3
  aEncArr4 ambi_encode a4,iOrder,kAzi4,kAlti4
  aEncArr5 ambi_encode a5,iOrder,kAzi5,kAlti5
  aEncArr6 ambi_encode a6,iOrder,kAzi6,kAlti6

  ;; sum arrays
  aOutArr[] init iAmbiChn
  trim aOutArr,iAmbiChn
  aOutArr[0] sum aEncArr1[0]/6,aEncArr2[0]/6,aEncArr3[0]/6,aEncArr4[0]/6,aEncArr5[0]/6,aEncArr6[0]/6
  aOutArr[1] sum aEncArr1[1]/6,aEncArr2[1]/6,aEncArr3[1]/6,aEncArr4[1]/6,aEncArr5[1]/6,aEncArr6[1]/6
  aOutArr[2] sum aEncArr1[2]/6,aEncArr2[2]/6,aEncArr3[2]/6,aEncArr4[2]/6,aEncArr5[2]/6,aEncArr6[2]/6
  aOutArr[3] sum aEncArr1[3]/6,aEncArr2[3]/6,aEncArr3[3]/6,aEncArr4[3]/6,aEncArr5[3]/6,aEncArr6[3]/6

    if iOrder < 2 goto end
    aOutArr[4] sum aEncArr1[4]/6,aEncArr2[4]/6,aEncArr3[4]/6,aEncArr4[4]/6,aEncArr5[4]/6,aEncArr6[4]/6
    aOutArr[5] sum aEncArr1[5]/6,aEncArr2[5]/6,aEncArr3[5]/6,aEncArr4[5]/6,aEncArr5[5]/6,aEncArr6[5]/6
    aOutArr[6] sum aEncArr1[6]/6,aEncArr2[6]/6,aEncArr3[6]/6,aEncArr4[6]/6,aEncArr5[6]/6,aEncArr6[6]/6
    aOutArr[7] sum aEncArr1[7]/6,aEncArr2[7]/6,aEncArr3[7]/6,aEncArr4[7]/6,aEncArr5[7]/6,aEncArr6[7]/6
    aOutArr[8] sum aEncArr1[8]/6,aEncArr2[8]/6,aEncArr3[8]/6,aEncArr4[8]/6,aEncArr5[8]/6,aEncArr6[8]/6
    
      if iOrder < 3 goto end
      aOutArr[9] sum aEncArr1[9]/6,aEncArr2[9]/6,aEncArr3[9]/6,aEncArr4[9]/6,aEncArr5[9]/6,aEncArr6[9]/6
      aOutArr[10] sum aEncArr1[10]/6,aEncArr2[10]/6,aEncArr3[10]/6,aEncArr4[10]/6,aEncArr5[10]/6,aEncArr6[10]/6
      aOutArr[11] sum aEncArr1[11]/6,aEncArr2[11]/6,aEncArr3[11]/6,aEncArr4[11]/6,aEncArr5[11]/6,aEncArr6[11]/6
      aOutArr[12] sum aEncArr1[12]/6,aEncArr2[12]/6,aEncArr3[12]/6,aEncArr4[12]/6,aEncArr5[12]/6,aEncArr6[12]/6
      aOutArr[13] sum aEncArr1[13]/6,aEncArr2[13]/6,aEncArr3[13]/6,aEncArr4[13]/6,aEncArr5[13]/6,aEncArr6[13]/6
      aOutArr[14] sum aEncArr1[14]/6,aEncArr2[14]/6,aEncArr3[14]/6,aEncArr4[14]/6,aEncArr5[14]/6,aEncArr6[14]/6
      aOutArr[15] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[15]/6,aEncArr6[15]/6

	if iOrder < 4 goto end
	aOutArr[16] sum aEncArr1[16]/6,aEncArr2[16]/6,aEncArr3[16]/6,aEncArr4[16]/6,aEncArr5[16]/6,aEncArr6[16]/6
	aOutArr[17] sum aEncArr1[17]/6,aEncArr2[17]/6,aEncArr3[17]/6,aEncArr4[17]/6,aEncArr5[17]/6,aEncArr6[17]/6
	aOutArr[18] sum aEncArr1[18]/6,aEncArr2[18]/6,aEncArr3[18]/6,aEncArr4[18]/6,aEncArr5[18]/6,aEncArr6[18]/6
	aOutArr[19] sum aEncArr1[19]/6,aEncArr2[19]/6,aEncArr3[19]/6,aEncArr4[19]/6,aEncArr5[19]/6,aEncArr6[19]/6
	aOutArr[20] sum aEncArr1[20]/6,aEncArr2[20]/6,aEncArr3[20]/6,aEncArr4[20]/6,aEncArr5[20]/6,aEncArr6[20]/6
	aOutArr[21] sum aEncArr1[21]/6,aEncArr2[21]/6,aEncArr3[21]/6,aEncArr4[21]/6,aEncArr5[21]/6,aEncArr6[21]/6
	aOutArr[22] sum aEncArr1[22]/6,aEncArr2[22]/6,aEncArr3[22]/6,aEncArr4[22]/6,aEncArr5[22]/6,aEncArr6[22]/6
	aOutArr[23] sum aEncArr1[23]/6,aEncArr2[23]/6,aEncArr3[23]/6,aEncArr4[23]/6,aEncArr5[23]/6,aEncArr6[23]/6
	aOutArr[24] sum aEncArr1[24]/6,aEncArr2[24]/6,aEncArr3[24]/6,aEncArr4[24]/6,aEncArr5[24]/6,aEncArr6[24]/6

	  if iOrder < 5 goto end
	  aOutArr[25] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[25]/6,aEncArr6[25]/6
	  aOutArr[26] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[26]/6,aEncArr6[26]/6
	  aOutArr[27] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[27]/6,aEncArr6[27]/6
	  aOutArr[28] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[28]/6,aEncArr6[28]/6
	  aOutArr[29] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[29]/6,aEncArr6[29]/6
	  aOutArr[30] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[30]/6,aEncArr6[30]/6
	  aOutArr[31] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[15]/6,aEncArr6[31]/6
	  aOutArr[32] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[15]/6,aEncArr6[32]/6
	  aOutArr[33] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[15]/6,aEncArr6[33]/6
	  aOutArr[34] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[15]/6,aEncArr6[34]/6
	  aOutArr[35] sum aEncArr1[15]/6,aEncArr2[15]/6,aEncArr3[15]/6,aEncArr4[15]/6,aEncArr5[15]/6,aEncArr6[35]/6

	    if iOrder < 6 goto end
	    aOutArr[36] sum aEncArr1[36]/6,aEncArr2[36]/6,aEncArr3[36]/6,aEncArr4[36]/6,aEncArr5[36]/6,aEncArr6[36]/6
	    aOutArr[37] sum aEncArr1[37]/6,aEncArr2[37]/6,aEncArr3[37]/6,aEncArr4[37]/6,aEncArr5[37]/6,aEncArr6[37]/6
	    aOutArr[38] sum aEncArr1[38]/6,aEncArr2[38]/6,aEncArr3[38]/6,aEncArr4[38]/6,aEncArr5[38]/6,aEncArr6[38]/6
	    aOutArr[39] sum aEncArr1[39]/6,aEncArr2[39]/6,aEncArr3[39]/6,aEncArr4[39]/6,aEncArr5[39]/6,aEncArr6[39]/6
	    aOutArr[40] sum aEncArr1[40]/6,aEncArr2[40]/6,aEncArr3[40]/6,aEncArr4[40]/6,aEncArr5[40]/6,aEncArr6[40]/6
	    aOutArr[41] sum aEncArr1[41]/6,aEncArr2[41]/6,aEncArr3[41]/6,aEncArr4[41]/6,aEncArr5[41]/6,aEncArr6[41]/6
	    aOutArr[42] sum aEncArr1[42]/6,aEncArr2[42]/6,aEncArr3[42]/6,aEncArr4[42]/6,aEncArr5[42]/6,aEncArr6[42]/6
	    aOutArr[43] sum aEncArr1[43]/6,aEncArr2[43]/6,aEncArr3[43]/6,aEncArr4[43]/6,aEncArr5[43]/6,aEncArr6[43]/6
	    aOutArr[44] sum aEncArr1[44]/6,aEncArr2[44]/6,aEncArr3[44]/6,aEncArr4[44]/6,aEncArr5[44]/6,aEncArr6[44]/6
	    aOutArr[45] sum aEncArr1[45]/6,aEncArr2[45]/6,aEncArr3[45]/6,aEncArr4[45]/6,aEncArr5[45]/6,aEncArr6[45]/6
	    aOutArr[46] sum aEncArr1[46]/6,aEncArr2[46]/6,aEncArr3[46]/6,aEncArr4[46]/6,aEncArr5[46]/6,aEncArr6[46]/6
	    aOutArr[47] sum aEncArr1[47]/6,aEncArr2[47]/6,aEncArr3[47]/6,aEncArr4[47]/6,aEncArr5[47]/6,aEncArr6[47]/6
	    aOutArr[48] sum aEncArr1[48]/6,aEncArr2[48]/6,aEncArr3[48]/6,aEncArr4[48]/6,aEncArr5[48]/6,aEncArr6[48]/6

	      if iOrder < 7 goto end
	      aOutArr[49] sum aEncArr1[49]/6,aEncArr2[49]/6,aEncArr3[49]/6,aEncArr4[49]/6,aEncArr5[49]/6,aEncArr6[49]/6
	      aOutArr[50] sum aEncArr1[50]/6,aEncArr2[50]/6,aEncArr3[50]/6,aEncArr4[50]/6,aEncArr5[50]/6,aEncArr6[50]/6
	      aOutArr[51] sum aEncArr1[51]/6,aEncArr2[51]/6,aEncArr3[51]/6,aEncArr4[51]/6,aEncArr5[51]/6,aEncArr6[51]/6
	      aOutArr[52] sum aEncArr1[52]/6,aEncArr2[52]/6,aEncArr3[52]/6,aEncArr4[52]/6,aEncArr5[52]/6,aEncArr6[52]/6
	      aOutArr[53] sum aEncArr1[53]/6,aEncArr2[53]/6,aEncArr3[53]/6,aEncArr4[53]/6,aEncArr5[53]/6,aEncArr6[53]/6
	      aOutArr[54] sum aEncArr1[54]/6,aEncArr2[54]/6,aEncArr3[54]/6,aEncArr4[54]/6,aEncArr5[54]/6,aEncArr6[54]/6
	      aOutArr[55] sum aEncArr1[55]/6,aEncArr2[55]/6,aEncArr3[55]/6,aEncArr4[55]/6,aEncArr5[55]/6,aEncArr6[55]/6
	      aOutArr[56] sum aEncArr1[56]/6,aEncArr2[56]/6,aEncArr3[56]/6,aEncArr4[56]/6,aEncArr5[56]/6,aEncArr6[56]/6
	      aOutArr[57] sum aEncArr1[57]/6,aEncArr2[57]/6,aEncArr3[57]/6,aEncArr4[57]/6,aEncArr5[57]/6,aEncArr6[57]/6
	      aOutArr[58] sum aEncArr1[58]/6,aEncArr2[58]/6,aEncArr3[58]/6,aEncArr4[58]/6,aEncArr5[58]/6,aEncArr6[58]/6
	      aOutArr[59] sum aEncArr1[59]/6,aEncArr2[59]/6,aEncArr3[59]/6,aEncArr4[59]/6,aEncArr5[59]/6,aEncArr6[59]/6
	      aOutArr[60] sum aEncArr1[60]/6,aEncArr2[60]/6,aEncArr3[60]/6,aEncArr4[60]/6,aEncArr5[60]/6,aEncArr6[60]/6
	      aOutArr[61] sum aEncArr1[61]/6,aEncArr2[61]/6,aEncArr3[61]/6,aEncArr4[61]/6,aEncArr5[61]/6,aEncArr6[61]/6
	      aOutArr[62] sum aEncArr1[62]/6,aEncArr2[62]/6,aEncArr3[62]/6,aEncArr4[62]/6,aEncArr5[62]/6,aEncArr6[62]/6
	      aOutArr[63] sum aEncArr1[63]/6,aEncArr2[63]/6,aEncArr3[63]/6,aEncArr4[63]/6,aEncArr5[63]/6,aEncArr6[63]/6

		if iOrder < 8 goto end
		aOutArr[64] sum aEncArr1[64]/6,aEncArr2[64]/6,aEncArr3[64]/6,aEncArr4[64]/6,aEncArr5[64]/6,aEncArr6[64]/6
		aOutArr[65] sum aEncArr1[65]/6,aEncArr2[65]/6,aEncArr3[65]/6,aEncArr4[65]/6,aEncArr5[65]/6,aEncArr6[65]/6
		aOutArr[66] sum aEncArr1[66]/6,aEncArr2[66]/6,aEncArr3[66]/6,aEncArr4[66]/6,aEncArr5[66]/6,aEncArr6[66]/6
		aOutArr[67] sum aEncArr1[67]/6,aEncArr2[67]/6,aEncArr3[67]/6,aEncArr4[67]/6,aEncArr5[67]/6,aEncArr6[67]/6
		aOutArr[68] sum aEncArr1[68]/6,aEncArr2[68]/6,aEncArr3[68]/6,aEncArr4[68]/6,aEncArr5[68]/6,aEncArr6[68]/6
		aOutArr[69] sum aEncArr1[69]/6,aEncArr2[69]/6,aEncArr3[69]/6,aEncArr4[69]/6,aEncArr5[69]/6,aEncArr6[69]/6
		aOutArr[70] sum aEncArr1[70]/6,aEncArr2[70]/6,aEncArr3[70]/6,aEncArr4[70]/6,aEncArr5[70]/6,aEncArr6[70]/6
		aOutArr[71] sum aEncArr1[71]/6,aEncArr2[71]/6,aEncArr3[71]/6,aEncArr4[71]/6,aEncArr5[71]/6,aEncArr6[71]/6
		aOutArr[72] sum aEncArr1[72]/6,aEncArr2[72]/6,aEncArr3[72]/6,aEncArr4[72]/6,aEncArr5[72]/6,aEncArr6[72]/6
		aOutArr[73] sum aEncArr1[73]/6,aEncArr2[73]/6,aEncArr3[73]/6,aEncArr4[73]/6,aEncArr5[73]/6,aEncArr6[73]/6
		aOutArr[74] sum aEncArr1[74]/6,aEncArr2[74]/6,aEncArr3[74]/6,aEncArr4[74]/6,aEncArr5[74]/6,aEncArr6[74]/6
		aOutArr[75] sum aEncArr1[75]/6,aEncArr2[75]/6,aEncArr3[75]/6,aEncArr4[75]/6,aEncArr5[75]/6,aEncArr6[75]/6
		aOutArr[76] sum aEncArr1[76]/6,aEncArr2[76]/6,aEncArr3[76]/6,aEncArr4[76]/6,aEncArr5[76]/6,aEncArr6[76]/6
		aOutArr[77] sum aEncArr1[77]/6,aEncArr2[77]/6,aEncArr3[77]/6,aEncArr4[77]/6,aEncArr5[77]/6,aEncArr6[77]/6
		aOutArr[78] sum aEncArr1[78]/6,aEncArr2[78]/6,aEncArr3[78]/6,aEncArr4[78]/6,aEncArr5[78]/6,aEncArr6[78]/6
		aOutArr[79] sum aEncArr1[79]/6,aEncArr2[79]/6,aEncArr3[79]/6,aEncArr4[79]/6,aEncArr5[79]/6,aEncArr6[79]/6
		aOutArr[80] sum aEncArr1[80]/6,aEncArr2[80]/6,aEncArr3[80]/6,aEncArr4[80]/6,aEncArr5[80]/6,aEncArr6[80]/6
		
	      end:
		  ;; output
		  xout aOutArr
		  ;; by philipp von neumann
endop

