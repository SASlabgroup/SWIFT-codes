/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: mean.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 05-Dec-2022 10:00:34
 */

/* Include Files */
#include "mean.h"
#include "NEDwaves_data.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_creal_T *x
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void b_mean(const emxArray_creal_T *x, emxArray_creal_T *y)
{
  const creal_T *x_data;
  creal_T *y_data;
  double bsum_im;
  double bsum_re;
  int hi;
  int ib;
  int k;
  int xblockoffset;
  int xi;
  x_data = x->data;
  if ((x->size[0] == 0) || (x->size[1] == 0)) {
    hi = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = x->size[1];
    emxEnsureCapacity_creal_T(y, hi);
    y_data = y->data;
    xblockoffset = x->size[1];
    for (hi = 0; hi < xblockoffset; hi++) {
      y_data[hi].re = 0.0;
      y_data[hi].im = 0.0;
    }
  } else {
    int firstBlockLength;
    int lastBlockLength;
    int nblocks;
    int npages;
    npages = x->size[1];
    hi = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = x->size[1];
    emxEnsureCapacity_creal_T(y, hi);
    y_data = y->data;
    if (x->size[0] <= 1024) {
      firstBlockLength = x->size[0];
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x->size[0] / 1024;
      lastBlockLength = x->size[0] - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (xi = 0; xi < npages; xi++) {
      int xpageoffset;
      xpageoffset = xi * x->size[0];
      y_data[xi] = x_data[xpageoffset];
      for (k = 2; k <= firstBlockLength; k++) {
        hi = (xpageoffset + k) - 1;
        y_data[xi].re += x_data[hi].re;
        y_data[xi].im += x_data[hi].im;
      }
      for (ib = 2; ib <= nblocks; ib++) {
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        bsum_re = x_data[xblockoffset].re;
        bsum_im = x_data[xblockoffset].im;
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (k = 2; k <= hi; k++) {
          int bsum_re_tmp;
          bsum_re_tmp = (xblockoffset + k) - 1;
          bsum_re += x_data[bsum_re_tmp].re;
          bsum_im += x_data[bsum_re_tmp].im;
        }
        y_data[xi].re += bsum_re;
        y_data[xi].im += bsum_im;
      }
    }
  }
  hi = y->size[0] * y->size[1];
  y->size[0] = 1;
  emxEnsureCapacity_creal_T(y, hi);
  y_data = y->data;
  bsum_re = x->size[0];
  xblockoffset = y->size[1] - 1;
  for (hi = 0; hi <= xblockoffset; hi++) {
    double ai;
    double re;
    bsum_im = y_data[hi].re;
    ai = y_data[hi].im;
    if (ai == 0.0) {
      re = bsum_im / bsum_re;
      bsum_im = 0.0;
    } else if (bsum_im == 0.0) {
      re = 0.0;
      bsum_im = ai / bsum_re;
    } else {
      re = bsum_im / bsum_re;
      bsum_im = ai / bsum_re;
    }
    y_data[hi].re = re;
    y_data[hi].im = bsum_im;
  }
}

/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_real_T *y
 * Return Type  : void
 */
void mean(const emxArray_real_T *x, emxArray_real_T *y)
{
  const double *x_data;
  double *y_data;
  int firstBlockLength;
  int ib;
  int k;
  int nblocks;
  int xi;
  x_data = x->data;
  if ((x->size[0] == 0) || (x->size[1] == 0)) {
    nblocks = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = x->size[1];
    emxEnsureCapacity_real_T(y, nblocks);
    y_data = y->data;
    firstBlockLength = x->size[1];
    for (nblocks = 0; nblocks < firstBlockLength; nblocks++) {
      y_data[nblocks] = 0.0;
    }
  } else {
    int lastBlockLength;
    int npages;
    npages = x->size[1];
    nblocks = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = x->size[1];
    emxEnsureCapacity_real_T(y, nblocks);
    y_data = y->data;
    if (x->size[0] <= 1024) {
      firstBlockLength = x->size[0];
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x->size[0] / 1024;
      lastBlockLength = x->size[0] - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (xi = 0; xi < npages; xi++) {
      int xpageoffset;
      xpageoffset = xi * x->size[0];
      y_data[xi] = x_data[xpageoffset];
      for (k = 2; k <= firstBlockLength; k++) {
        y_data[xi] += x_data[(xpageoffset + k) - 1];
      }
      for (ib = 2; ib <= nblocks; ib++) {
        double bsum;
        int hi;
        int xblockoffset;
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        bsum = x_data[xblockoffset];
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (k = 2; k <= hi; k++) {
          bsum += x_data[(xblockoffset + k) - 1];
        }
        y_data[xi] += bsum;
      }
    }
  }
  nblocks = y->size[0] * y->size[1];
  y->size[0] = 1;
  emxEnsureCapacity_real_T(y, nblocks);
  y_data = y->data;
  firstBlockLength = y->size[1] - 1;
  for (nblocks = 0; nblocks <= firstBlockLength; nblocks++) {
    y_data[nblocks] /= (double)x->size[0];
  }
}

/*
 * File trailer for mean.c
 *
 * [EOF]
 */
