/* lorenz_array
creates arrays based on the lorenz attractor
for every plane in a 3D field it creates a array and calculates
movement of a virtual point and saves the positions in the arrays
- iArr_Size -> Size of array
- iX_Start -> Start Value of the virtual point on x-axis
- iY_Start -> Start Value of the virtual point on y-axis
- iZ_Start -> Start Value of the virtual point on z-axis
- iStepSize -> allows skipping of values that are written to the
arrays
- iSigma -> value of the constant Sigma; default to 10
- iRho -> value of the constant Rho; default to 28
- iBeta -> value of the constant Beta; default to 8/3
*/

opcode lorenz_arrays, i[]i[]i[], iiiipjjj
  iArr_Size, iX_Start, iY_Start, iZ_Start, iStepSize, iSigma, iRho, iBeta xin

  iXarr[] init iArr_Size
  iYarr[] init iArr_Size
  iZarr[] init iArr_Size

  ix init iX_Start
  iy init iY_Start
  iz init iZ_Start

  if iSigma == -1 then
    iSigma = 10
  else
    iSigma = iSigma
  endif
  if iRho == -1 then
    iRho = 28
  else
    iRho = iRho
  endif
  if iBeta == -1 then
    iBeta = 8./3.
  else
    iBeta = iBeta
  endif

  iDt = 0.001
    
  iIndx init 0
  iIndxIncr init 0
  
  loop_write_array:
  iXarr[iIndx] = ix
  iYarr[iIndx] = iy
  iZarr[iIndx] = iz

  loop_step_size:
  ix += (iSigma * (iy - ix)) * iDt
  iy += (ix * (iRho - iz) - iy) * iDt
  iz += ((ix * iy) - (iBeta * iz)) * iDt
  loop_lt iIndxIncr, 1, iStepSize, loop_step_size
  iIndxIncr = 0
  
  loop_lt iIndx, 1, iArr_Size, loop_write_array
  
  xout iXarr, iYarr, iZarr
endop
