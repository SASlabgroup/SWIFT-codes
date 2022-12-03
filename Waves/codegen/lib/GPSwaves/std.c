/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: std.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "std.h"
#include "GPSwaves_emxutil.h"
#include "combineVectorElements.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *x
 * Return Type  : double
 */
double b_std(const emxArray_real_T *x)
{
  double y;
  emxArray_real_T *absdiff;
  int b_x[1];
  emxArray_real_T c_x;
  double xbar;
  int k;
  double absxk;
  double t;
  if (x->size[1] == 0) {
    y = rtNaN;
  } else if (x->size[1] == 1) {
    if ((!rtIsInf(x->data[0])) && (!rtIsNaN(x->data[0]))) {
      y = 0.0;
    } else {
      y = rtNaN;
    }
  } else {
    emxInit_real_T1(&absdiff, 1);
    b_x[0] = x->size[1];
    c_x = *x;
    c_x.size = (int *)&b_x;
    c_x.numDimensions = 1;
    xbar = combineVectorElements(&c_x, x->size[1]) / (double)x->size[1];
    k = absdiff->size[0];
    absdiff->size[0] = x->size[1];
    emxEnsureCapacity_real_T(absdiff, k);
    for (k = 0; k + 1 <= x->size[1]; k++) {
      absdiff->data[k] = fabs(x->data[k] - xbar);
    }

    y = 0.0;
    xbar = 3.3121686421112381E-170;
    for (k = 1; k <= x->size[1]; k++) {
      absxk = absdiff->data[k - 1];
      if (absxk > xbar) {
        t = xbar / absxk;
        y = 1.0 + y * t * t;
        xbar = absxk;
      } else {
        t = absxk / xbar;
        y += t * t;
      }
    }

    emxFree_real_T(&absdiff);
    y = xbar * sqrt(y);
    y /= sqrt((double)x->size[1] - 1.0);
  }

  return y;
}

/*
 * File trailer for std.c
 *
 * [EOF]
 */
