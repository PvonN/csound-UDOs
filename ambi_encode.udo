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

