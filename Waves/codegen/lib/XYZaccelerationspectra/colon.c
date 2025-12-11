/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: colon.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 11-Dec-2025 06:39:36
 */

/* Include Files */
#include "colon.h"
#include "XYZaccelerationspectra_emxutil.h"
#include "XYZaccelerationspectra_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : double a
 *                double d
 *                double b
 *                emxArray_real_T *y
 * Return Type  : void
 */
void eml_float_colon(double a, double d, double b, emxArray_real_T *y)
{
  double apnd;
  double cdiff;
  double ndbl;
  double *y_data;
  int k;
  int n;
  int nm1d2;
  ndbl = floor((b - a) / d + 0.5);
  apnd = a + ndbl * d;
  if (d > 0.0) {
    cdiff = apnd - b;
  } else {
    cdiff = b - apnd;
  }
  if (fabs(cdiff) < 4.4408920985006262E-16 * fmax(fabs(a), fabs(b))) {
    ndbl++;
    apnd = b;
  } else if (cdiff > 0.0) {
    apnd = a + (ndbl - 1.0) * d;
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
    y_data[0] = a;
    if (n > 1) {
      y_data[n - 1] = apnd;
      nm1d2 = (n - 1) / 2;
      for (k = 0; k <= nm1d2 - 2; k++) {
        ndbl = ((double)k + 1.0) * d;
        y_data[k + 1] = a + ndbl;
        y_data[(n - k) - 2] = apnd - ndbl;
      }
      if (nm1d2 << 1 == n - 1) {
        y_data[nm1d2] = (a + apnd) / 2.0;
      } else {
        ndbl = (double)nm1d2 * d;
        y_data[nm1d2] = a + ndbl;
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
