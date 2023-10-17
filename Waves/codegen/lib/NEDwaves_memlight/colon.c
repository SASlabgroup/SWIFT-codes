/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: colon.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 16-Oct-2023 17:01:43
 */

/* Include Files */
#include "colon.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : double b
 *                emxArray_real_T *y
 * Return Type  : void
 */
void b_eml_float_colon(double b, emxArray_real_T *y)
{
  double apnd;
  double cdiff;
  double ndbl;
  double *y_data;
  int k;
  int n;
  int nm1d2;
  ndbl = floor((b - 0.009765625) / 0.01171875 + 0.5);
  apnd = ndbl * 0.01171875 + 0.009765625;
  cdiff = apnd - b;
  if (fabs(cdiff) < 4.4408920985006262E-16 * fmax(0.009765625, fabs(b))) {
    ndbl++;
    apnd = b;
  } else if (cdiff > 0.0) {
    apnd = (ndbl - 1.0) * 0.01171875 + 0.009765625;
  } else {
    ndbl++;
  }
  if (ndbl >= 0.0) {
    n = (int)ndbl;
  } else {
    n = 0;
  }
  nm1d2 = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = n;
  emxEnsureCapacity_real_T(y, nm1d2);
  y_data = y->data;
  if (n > 0) {
    y_data[0] = 0.009765625;
    if (n > 1) {
      y_data[n - 1] = apnd;
      nm1d2 = (n - 1) / 2;
      for (k = 0; k <= nm1d2 - 2; k++) {
        ndbl = ((double)k + 1.0) * 0.01171875;
        y_data[k + 1] = ndbl + 0.009765625;
        y_data[(n - k) - 2] = apnd - ndbl;
      }
      if (nm1d2 << 1 == n - 1) {
        y_data[nm1d2] = (apnd + 0.009765625) / 2.0;
      } else {
        ndbl = (double)nm1d2 * 0.01171875;
        y_data[nm1d2] = ndbl + 0.009765625;
        y_data[nm1d2 + 1] = apnd - ndbl;
      }
    }
  }
}

/*
 * Arguments    : double b
 *                emxArray_real_T *y
 * Return Type  : void
 */
void eml_float_colon(double b, emxArray_real_T *y)
{
  double apnd;
  double cdiff;
  double ndbl;
  double *y_data;
  int k;
  int n;
  int nm1d2;
  ndbl = floor((b - 0.00390625) / 0.00390625 + 0.5);
  apnd = ndbl * 0.00390625 + 0.00390625;
  cdiff = apnd - b;
  if (fabs(cdiff) < 4.4408920985006262E-16 * fmax(0.00390625, fabs(b))) {
    ndbl++;
    apnd = b;
  } else if (cdiff > 0.0) {
    apnd = (ndbl - 1.0) * 0.00390625 + 0.00390625;
  } else {
    ndbl++;
  }
  if (ndbl >= 0.0) {
    n = (int)ndbl;
  } else {
    n = 0;
  }
  nm1d2 = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = n;
  emxEnsureCapacity_real_T(y, nm1d2);
  y_data = y->data;
  if (n > 0) {
    y_data[0] = 0.00390625;
    if (n > 1) {
      y_data[n - 1] = apnd;
      nm1d2 = (n - 1) / 2;
      for (k = 0; k <= nm1d2 - 2; k++) {
        ndbl = ((double)k + 1.0) * 0.00390625;
        y_data[k + 1] = ndbl + 0.00390625;
        y_data[(n - k) - 2] = apnd - ndbl;
      }
      if (nm1d2 << 1 == n - 1) {
        y_data[nm1d2] = (apnd + 0.00390625) / 2.0;
      } else {
        ndbl = (double)nm1d2 * 0.00390625;
        y_data[nm1d2] = ndbl + 0.00390625;
        y_data[nm1d2 + 1] = apnd - ndbl;
      }
    }
  }
}

/*
 * File trailer for colon.c
 *
 * [EOF]
 */
