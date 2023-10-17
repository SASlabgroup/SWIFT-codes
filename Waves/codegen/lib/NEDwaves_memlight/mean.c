/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: mean.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 16-Oct-2023 17:01:43
 */

/* Include Files */
#include "mean.h"
#include "NEDwaves_memlight_data.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_creal32_T *x
 * Return Type  : creal32_T
 */
creal32_T mean(const emxArray_creal32_T *x)
{
  const creal32_T *x_data;
  creal32_T y;
  float x_im;
  float x_re;
  int ib;
  int k;
  x_data = x->data;
  if (x->size[1] == 0) {
    x_re = 0.0F;
    x_im = 0.0F;
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
    x_re = x_data[0].re;
    x_im = x_data[0].im;
    for (k = 2; k <= firstBlockLength; k++) {
      x_re += x_data[k - 1].re;
      x_im += x_data[k - 1].im;
    }
    for (ib = 2; ib <= nblocks; ib++) {
      float bsum_im;
      float bsum_re;
      int hi;
      firstBlockLength = (ib - 1) << 10;
      bsum_re = x_data[firstBlockLength].re;
      bsum_im = x_data[firstBlockLength].im;
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (k = 2; k <= hi; k++) {
        int bsum_re_tmp;
        bsum_re_tmp = (firstBlockLength + k) - 1;
        bsum_re += x_data[bsum_re_tmp].re;
        bsum_im += x_data[bsum_re_tmp].im;
      }
      x_re += bsum_re;
      x_im += bsum_im;
    }
  }
  if (x_im == 0.0F) {
    y.re = x_re / (float)x->size[1];
    y.im = 0.0F;
  } else if (x_re == 0.0F) {
    y.re = 0.0F;
    y.im = x_im / (float)x->size[1];
  } else {
    y.re = x_re / (float)x->size[1];
    y.im = x_im / (float)x->size[1];
  }
  return y;
}

/*
 * File trailer for mean.c
 *
 * [EOF]
 */
