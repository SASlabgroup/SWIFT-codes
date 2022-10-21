/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: var.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "var.h"
#include "combineVectorElements.h"
#include "GPSwaves_emxutil.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_real_T *y
 * Return Type  : void
 */
void var(const emxArray_real_T *x, emxArray_real_T *y)
{
  int environment_idx_0;
  int i1;
  unsigned int szy[2];
  int loop_ub;
  int nx;
  int p;
  emxArray_real_T *xv;
  int outsize_idx_0;
  int b_environment_idx_0;
  double xbar;
  double yv;
  double t;
  environment_idx_0 = x->size[0];
  for (i1 = 0; i1 < 2; i1++) {
    szy[i1] = (unsigned int)x->size[i1];
  }

  i1 = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = (int)szy[1];
  emxEnsureCapacity_real_T1(y, i1);
  loop_ub = (int)szy[1];
  for (i1 = 0; i1 < loop_ub; i1++) {
    y->data[i1] = 0.0;
  }

  nx = x->size[0];
  p = 0;
  emxInit_real_T1(&xv, 1);
  if (1 <= x->size[1]) {
    outsize_idx_0 = nx;
  }

  while (p + 1 <= x->size[1]) {
    b_environment_idx_0 = p * nx + 1;
    i1 = xv->size[0];
    xv->size[0] = outsize_idx_0;
    emxEnsureCapacity_real_T(xv, i1);
    for (i1 = 0; i1 < outsize_idx_0; i1++) {
      xv->data[i1] = 0.0;
    }

    for (loop_ub = -1; loop_ub + 2 <= nx; loop_ub++) {
      xv->data[loop_ub + 1] = x->data[b_environment_idx_0 + loop_ub];
    }

    xbar = combineVectorElements(xv, environment_idx_0) / (double)
      environment_idx_0;
    yv = 0.0;
    for (loop_ub = 1; loop_ub <= environment_idx_0; loop_ub++) {
      t = xv->data[loop_ub - 1] - xbar;
      yv += t * t;
    }

    yv /= (double)environment_idx_0 - 1.0;
    y->data[p] = yv;
    p++;
  }

  emxFree_real_T(&xv);
}

/*
 * File trailer for var.c
 *
 * [EOF]
 */
