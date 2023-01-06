/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: mean.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

/* Include Files */
#include "mean.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real32_T *x
 * Return Type  : float
 */
float mean(const emxArray_real32_T *x)
{
  const float *x_data;
  float b_x;
  int ib;
  int k;
  x_data = x->data;
  if (x->size[1] == 0) {
    b_x = 0.0F;
  } else {
    int firstBlockLength;
    int lastBlockLength;
    int nblocks;
    if (x->size[1] <= 1024) {
      firstBlockLength = x->size[1];
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x->size[1] / 1024;
      lastBlockLength = x->size[1] - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    b_x = x_data[0];
    for (k = 2; k <= firstBlockLength; k++) {
      b_x += x_data[k - 1];
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
      b_x += bsum;
    }
  }
  return b_x / (float)x->size[1];
}

/*
 * File trailer for mean.c
 *
 * [EOF]
 */
