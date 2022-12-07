/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: blockedSummation.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "blockedSummation.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real32_T *x
 *                int vlen
 * Return Type  : float
 */
float blockedSummation(const emxArray_real32_T *x, int vlen)
{
  const float *x_data;
  float y;
  int ib;
  int k;
  x_data = x->data;
  if ((x->size[0] == 0) || (vlen == 0)) {
    y = 0.0F;
  } else {
    int firstBlockLength;
    int lastBlockLength;
    int nblocks;
    if (vlen <= 1024) {
      firstBlockLength = vlen;
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = vlen / 1024;
      lastBlockLength = vlen - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    y = x_data[0];
    for (k = 2; k <= firstBlockLength; k++) {
      y += x_data[k - 1];
    }
    for (ib = 2; ib <= nblocks; ib++) {
      float bsum;
      int hi;
      firstBlockLength = (ib - 1) << 10;
      bsum = x_data[firstBlockLength];
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (k = 2; k <= hi; k++) {
        bsum += x_data[(firstBlockLength + k) - 1];
      }
      y += bsum;
    }
  }
  return y;
}

/*
 * File trailer for blockedSummation.c
 *
 * [EOF]
 */
