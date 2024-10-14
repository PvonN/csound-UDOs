/*
This comment is taken from Michael Edwards contrast-enhancement object
for Max/MSP:
This algorithm is taken from CLM.  Here's Bill Schottstaedt's comment
from there: "contrast-enhancement phase-modulates a sound file. It's
like audio MSG. The actual algorithm is sin(in-samp * pi/2 + (fm-index
* sin(in-samp * 2*pi))). The result is to brighten the sound, helping
it cut through a huge mix."
*/
opcode contrast_enhancement, a, ak
  aIn, kAmount xin

  aSig1 = aIn * ($M_PI / 2)
  aSig2 = sin(aIn * ($M_PI * 2)) * kAmount

  aOut = sin(aSig1 + aSig2)
  aOut dcblock2 aOut
  
  xout aOut
endop
