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

