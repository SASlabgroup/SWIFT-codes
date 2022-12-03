/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: sqrt.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "sqrt.h"
#include "GPSwaves_emxutil.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_real_T *b_x
 * Return Type  : void
 */
void b_sqrt(const emxArray_real_T *x, emxArray_real_T *b_x)
{
  int i3;
  int loop_ub;
  i3 = b_x->size[0] * b_x->size[1];
  b_x->size[0] = 1;
  b_x->size[1] = x->size[1];
  emxEnsureCapacity_real_T1(b_x, i3);
  loop_ub = x->size[0] * x->size[1];
  for (i3 = 0; i3 < loop_ub; i3++) {
    b_x->data[i3] = x->data[i3];
  }

  d_sqrt(b_x);
}

/*
 * Arguments    : double *x
 * Return Type  : void
 */
void c_sqrt(double *x)
{
  *x = sqrt(*x);
}

/*
 * Arguments    : emxArray_real_T *x
 * Return Type  : void
 */
void d_sqrt(emxArray_real_T *x)
{
  int nx;
  int k;
  nx = x->size[1];
  for (k = 0; k + 1 <= nx; k++) {
    x->data[k] = sqrt(x->data[k]);
  }
}

/*
 * File trailer for sqrt.c
 *
 * [EOF]
 */
