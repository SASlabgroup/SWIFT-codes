/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: var.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "var.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_real_T *y
 * Return Type  : void
 */
void var(const emxArray_real_T *x, emxArray_real_T *y)
{
  emxArray_real_T *xv;
  const double *x_data;
  double *xv_data;
  double *y_data;
  int firstBlockLength;
  int hi;
  int ib;
  int k;
  int loop_ub;
  int n;
  int npages;
  int nx;
  int outsize_idx_0;
  int p;
  x_data = x->data;
  hi = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = x->size[1];
  emxEnsureCapacity_real_T(y, hi);
  y_data = y->data;
  firstBlockLength = x->size[1];
  for (hi = 0; hi < firstBlockLength; hi++) {
    y_data[hi] = 0.0;
  }
  nx = x->size[0];
  npages = x->size[1];
  if (x->size[1] - 1 >= 0) {
    outsize_idx_0 = x->size[0];
    loop_ub = x->size[0];
    n = x->size[0];
  }
  emxInit_real_T(&xv, 1);
  for (p = 0; p < npages; p++) {
    firstBlockLength = p * nx;
    hi = xv->size[0];
    xv->size[0] = outsize_idx_0;
    emxEnsureCapacity_real_T(xv, hi);
    xv_data = xv->data;
    for (hi = 0; hi < loop_ub; hi++) {
      xv_data[hi] = 0.0;
    }
    for (k = 0; k < nx; k++) {
      xv_data[k] = x_data[firstBlockLength + k];
    }
    if (x->size[0] == 0) {
      y_data[p] = rtNaN;
    } else if (x->size[0] == 1) {
      if ((!rtIsInf(xv_data[0])) && (!rtIsNaN(xv_data[0]))) {
        y_data[p] = 0.0;
      } else {
        y_data[p] = rtNaN;
      }
    } else {
      double bsum;
      double xbar;
      if (xv->size[0] == 0) {
        xbar = 0.0;
      } else {
        int lastBlockLength;
        int nblocks;
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
        xbar = xv_data[0];
        for (k = 2; k <= firstBlockLength; k++) {
          xbar += xv_data[k - 1];
        }
        for (ib = 2; ib <= nblocks; ib++) {
          firstBlockLength = (ib - 1) << 10;
          bsum = xv_data[firstBlockLength];
          if (ib == nblocks) {
            hi = lastBlockLength;
          } else {
            hi = 1024;
          }
          for (k = 2; k <= hi; k++) {
            bsum += xv_data[(firstBlockLength + k) - 1];
          }
          xbar += bsum;
        }
      }
      xbar /= (double)x->size[0];
      bsum = 0.0;
      for (k = 0; k < n; k++) {
        double t;
        t = xv_data[k] - xbar;
        bsum += t * t;
      }
      y_data[p] = bsum / ((double)x->size[0] - 1.0);
    }
  }
  emxFree_real_T(&xv);
}

/*
 * File trailer for var.c
 *
 * [EOF]
 */
