/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xscal.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "xscal.h"

/* Function Definitions */

/*
 * Arguments    : int n
 *                double a
 *                emxArray_real_T *x
 *                int ix0
 * Return Type  : void
 */
void xscal(int n, double a, emxArray_real_T *x, int ix0)
{
  int i6;
  int k;
  i6 = (ix0 + n) - 1;
  for (k = ix0; k <= i6; k++) {
    x->data[k - 1] *= a;
  }
}

/*
 * File trailer for xscal.c
 *
 * [EOF]
 */
