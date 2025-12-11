/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: nullAssignment.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 11-Dec-2025 06:39:36
 */

/* Include Files */
#include "nullAssignment.h"
#include "XYZaccelerationspectra_emxutil.h"
#include "XYZaccelerationspectra_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : emxArray_creal32_T *x
 *                const emxArray_int32_T *idx
 * Return Type  : void
 */
void nullAssignment(emxArray_creal32_T *x, const emxArray_int32_T *idx)
{
  emxArray_boolean_T *b;
  creal32_T *x_data;
  const int *idx_data;
  int i;
  int k;
  int k0;
  int nxin;
  int nxout;
  bool *b_data;
  idx_data = idx->data;
  x_data = x->data;
  emxInit_boolean_T(&b);
  nxin = x->size[1];
  i = b->size[0] * b->size[1];
  b->size[0] = 1;
  b->size[1] = x->size[1];
  emxEnsureCapacity_boolean_T(b, i);
  b_data = b->data;
  k0 = x->size[1];
  for (i = 0; i < k0; i++) {
    b_data[i] = false;
  }
  i = idx->size[1];
  for (k = 0; k < i; k++) {
    b_data[idx_data[k] - 1] = true;
  }
  k0 = 0;
  i = b->size[1];
  for (k = 0; k < i; k++) {
    k0 += b_data[k];
  }
  nxout = x->size[1] - k0;
  k0 = -1;
  for (k = 0; k < nxin; k++) {
    if ((k + 1 > b->size[1]) || (!b_data[k])) {
      k0++;
      x_data[k0] = x_data[k];
    }
  }
  emxFree_boolean_T(&b);
  i = x->size[0] * x->size[1];
  if (nxout < 1) {
    x->size[1] = 0;
  } else {
    x->size[1] = nxout;
  }
  emxEnsureCapacity_creal32_T(x, i);
}

/*
 * File trailer for nullAssignment.c
 *
 * [EOF]
 */
