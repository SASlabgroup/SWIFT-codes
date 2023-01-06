/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: var.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

/* Include Files */
#include "var.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real32_T *x
 * Return Type  : float
 */
float var(const emxArray_real32_T *x)
{
  const float *x_data;
  float y;
  int ib;
  int k;
  int n;
  x_data = x->data;
  n = x->size[1];
  if (x->size[1] == 0) {
    y = rtNaNF;
  } else if (x->size[1] == 1) {
    if ((!rtIsInfF(x_data[0])) && (!rtIsNaNF(x_data[0]))) {
      y = 0.0F;
    } else {
      y = rtNaNF;
    }
  } else {
    float bsum;
    float xbar;
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
    xbar = x_data[0];
    for (k = 2; k <= firstBlockLength; k++) {
      xbar += x_data[k - 1];
    }
    for (ib = 2; ib <= nblocks; ib++) {
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
      xbar += bsum;
    }
    xbar /= (float)x->size[1];
    y = 0.0F;
    for (k = 0; k < n; k++) {
      bsum = x_data[k] - xbar;
      y += bsum * bsum;
    }
    y /= (float)(x->size[1] - 1);
  }
  return y;
}

/*
 * File trailer for var.c
 *
 * [EOF]
 */
