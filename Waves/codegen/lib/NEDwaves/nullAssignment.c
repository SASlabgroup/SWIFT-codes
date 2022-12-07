/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: nullAssignment.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "nullAssignment.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : emxArray_creal32_T *x
 * Return Type  : void
 */
void b_nullAssignment(emxArray_creal32_T *x)
{
  creal32_T *x_data;
  int i;
  int j;
  int ncolx;
  int nrows;
  int nrowx;
  x_data = x->data;
  nrowx = x->size[0] - 2;
  ncolx = x->size[1];
  nrows = x->size[0] - 1;
  for (j = 0; j < ncolx; j++) {
    for (i = 0; i < nrows; i++) {
      x_data[i + x->size[0] * j] = x_data[(i + x->size[0] * j) + 1];
    }
  }
  if (nrows < 1) {
    nrowx = 0;
  } else {
    nrowx++;
  }
  ncolx = x->size[1] - 1;
  for (nrows = 0; nrows <= ncolx; nrows++) {
    for (j = 0; j < nrowx; j++) {
      x_data[j + nrowx * nrows] = x_data[j + x->size[0] * nrows];
    }
  }
  nrows = x->size[0] * x->size[1];
  x->size[0] = nrowx;
  x->size[1] = ncolx + 1;
  emxEnsureCapacity_creal32_T(x, nrows);
}

/*
 * Arguments    : emxArray_real_T *x
 *                const emxArray_boolean_T *idx
 * Return Type  : void
 */
void c_nullAssignment(emxArray_real_T *x, const emxArray_boolean_T *idx)
{
  double *x_data;
  int i;
  int k;
  int k0;
  int nxin;
  int nxout;
  const bool *idx_data;
  idx_data = idx->data;
  x_data = x->data;
  nxin = x->size[1];
  k0 = 0;
  i = idx->size[1];
  for (k = 0; k < i; k++) {
    k0 += idx_data[k];
  }
  nxout = x->size[1] - k0;
  k0 = -1;
  for (k = 0; k < nxin; k++) {
    if ((k + 1 > idx->size[1]) || (!idx_data[k])) {
      k0++;
      x_data[k0] = x_data[k];
    }
  }
  i = x->size[0] * x->size[1];
  if (nxout < 1) {
    x->size[1] = 0;
  } else {
    x->size[1] = nxout;
  }
  emxEnsureCapacity_real_T(x, i);
}

/*
 * Arguments    : emxArray_creal_T *x
 *                const emxArray_boolean_T *idx
 * Return Type  : void
 */
void d_nullAssignment(emxArray_creal_T *x, const emxArray_boolean_T *idx)
{
  creal_T *x_data;
  int i;
  int k;
  int k0;
  int nxin;
  int nxout;
  const bool *idx_data;
  idx_data = idx->data;
  x_data = x->data;
  nxin = x->size[1];
  k0 = 0;
  i = idx->size[1];
  for (k = 0; k < i; k++) {
    k0 += idx_data[k];
  }
  nxout = x->size[1] - k0;
  k0 = -1;
  for (k = 0; k < nxin; k++) {
    if ((k + 1 > idx->size[1]) || (!idx_data[k])) {
      k0++;
      x_data[k0] = x_data[k];
    }
  }
  i = x->size[0] * x->size[1];
  if (nxout < 1) {
    x->size[1] = 0;
  } else {
    x->size[1] = nxout;
  }
  emxEnsureCapacity_creal_T(x, i);
}

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
  int b_i;
  int i;
  int j;
  int k;
  int ncolx;
  int nrows;
  int nrowx;
  bool *b_data;
  idx_data = idx->data;
  x_data = x->data;
  nrowx = x->size[0];
  ncolx = x->size[1] - 1;
  if (idx->size[1] == 1) {
    nrows = x->size[0] - 1;
    for (j = 0; j <= ncolx; j++) {
      i = idx_data[0];
      for (b_i = i; b_i <= nrows; b_i++) {
        x_data[(b_i + x->size[0] * j) - 1] = x_data[b_i + x->size[0] * j];
      }
    }
  } else {
    emxInit_boolean_T(&b, 2);
    i = b->size[0] * b->size[1];
    b->size[0] = 1;
    b->size[1] = x->size[0];
    emxEnsureCapacity_boolean_T(b, i);
    b_data = b->data;
    b_i = x->size[0];
    for (i = 0; i < b_i; i++) {
      b_data[i] = false;
    }
    i = idx->size[1];
    for (k = 0; k < i; k++) {
      b_data[idx_data[k] - 1] = true;
    }
    nrows = 0;
    i = b->size[1];
    for (k = 0; k < i; k++) {
      nrows += b_data[k];
    }
    nrows = x->size[0] - nrows;
    b_i = 0;
    for (k = 0; k < nrowx; k++) {
      if ((k + 1 > b->size[1]) || (!b_data[k])) {
        for (j = 0; j <= ncolx; j++) {
          x_data[b_i + x->size[0] * j] = x_data[k + x->size[0] * j];
        }
        b_i++;
      }
    }
    emxFree_boolean_T(&b);
  }
  if (nrows < 1) {
    b_i = 0;
  } else {
    b_i = nrows;
  }
  nrows = x->size[1] - 1;
  for (i = 0; i <= nrows; i++) {
    for (nrowx = 0; nrowx < b_i; nrowx++) {
      x_data[nrowx + b_i * i] = x_data[nrowx + x->size[0] * i];
    }
  }
  i = x->size[0] * x->size[1];
  x->size[0] = b_i;
  x->size[1] = nrows + 1;
  emxEnsureCapacity_creal32_T(x, i);
}

/*
 * File trailer for nullAssignment.c
 *
 * [EOF]
 */
