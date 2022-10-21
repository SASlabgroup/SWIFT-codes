/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: mean.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "mean.h"
#include "GPSwaves_emxutil.h"
#include "combineVectorElements.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_real_T *y
 * Return Type  : void
 */
void b_mean(const emxArray_real_T *x, emxArray_real_T *y)
{
  int i;
  unsigned int sz[2];
  int xpageoffset;
  int k;
  if ((x->size[0] == 0) || (x->size[1] == 0)) {
    for (i = 0; i < 2; i++) {
      sz[i] = (unsigned int)x->size[i];
    }

    i = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = (int)sz[1];
    emxEnsureCapacity_real_T1(y, i);
    xpageoffset = (int)sz[1];
    for (i = 0; i < xpageoffset; i++) {
      y->data[i] = 0.0;
    }
  } else {
    i = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = x->size[1];
    emxEnsureCapacity_real_T1(y, i);
    for (i = 0; i + 1 <= x->size[1]; i++) {
      xpageoffset = i * x->size[0];
      y->data[i] = x->data[xpageoffset];
      for (k = 2; k <= x->size[0]; k++) {
        y->data[i] += x->data[(xpageoffset + k) - 1];
      }
    }
  }

  i = y->size[0] * y->size[1];
  y->size[0] = 1;
  emxEnsureCapacity_real_T1(y, i);
  i = y->size[0];
  xpageoffset = y->size[1];
  k = x->size[0];
  xpageoffset *= i;
  for (i = 0; i < xpageoffset; i++) {
    y->data[i] /= (double)k;
  }
}

/*
 * Arguments    : const emxArray_creal_T *x
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void c_mean(const emxArray_creal_T *x, emxArray_creal_T *y)
{
  int i;
  unsigned int sz[2];
  int xpageoffset;
  int k;
  double y_re;
  double y_im;
  if ((x->size[0] == 0) || (x->size[1] == 0)) {
    for (i = 0; i < 2; i++) {
      sz[i] = (unsigned int)x->size[i];
    }

    i = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = (int)sz[1];
    emxEnsureCapacity_creal_T(y, i);
    xpageoffset = (int)sz[1];
    for (i = 0; i < xpageoffset; i++) {
      y->data[i].re = 0.0;
      y->data[i].im = 0.0;
    }
  } else {
    i = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = x->size[1];
    emxEnsureCapacity_creal_T(y, i);
    for (i = 0; i + 1 <= x->size[1]; i++) {
      xpageoffset = i * x->size[0];
      y->data[i] = x->data[xpageoffset];
      for (k = 2; k <= x->size[0]; k++) {
        y->data[i].re += x->data[(xpageoffset + k) - 1].re;
        y->data[i].im += x->data[(xpageoffset + k) - 1].im;
      }
    }
  }

  i = y->size[0] * y->size[1];
  y->size[0] = 1;
  emxEnsureCapacity_creal_T(y, i);
  i = y->size[0];
  xpageoffset = y->size[1];
  k = x->size[0];
  xpageoffset *= i;
  for (i = 0; i < xpageoffset; i++) {
    y_re = y->data[i].re;
    y_im = y->data[i].im;
    if (y_im == 0.0) {
      y->data[i].re = y_re / (double)k;
      y->data[i].im = 0.0;
    } else if (y_re == 0.0) {
      y->data[i].re = 0.0;
      y->data[i].im = y_im / (double)k;
    } else {
      y->data[i].re = y_re / (double)k;
      y->data[i].im = y_im / (double)k;
    }
  }
}

/*
 * Arguments    : const emxArray_real_T *x
 * Return Type  : double
 */
double mean(const emxArray_real_T *x)
{
  return b_combineVectorElements(x) / (double)x->size[1];
}

/*
 * File trailer for mean.c
 *
 * [EOF]
 */
