/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xnrm2.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "xnrm2.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : int n
 *                const emxArray_real_T *x
 *                int ix0
 * Return Type  : double
 */
double b_xnrm2(int n, const emxArray_real_T *x, int ix0)
{
  const double *x_data;
  double scale;
  double y;
  int k;
  int kend;
  x_data = x->data;
  y = 0.0;
  scale = 3.3121686421112381E-170;
  kend = (ix0 + n) - 1;
  for (k = ix0; k <= kend; k++) {
    double absxk;
    absxk = fabs(x_data[k - 1]);
    if (absxk > scale) {
      double t;
      t = scale / absxk;
      y = y * t * t + 1.0;
      scale = absxk;
    } else {
      double t;
      t = absxk / scale;
      y += t * t;
    }
  }
  return scale * sqrt(y);
}

/*
 * Arguments    : int n
 *                const emxArray_real32_T *x
 *                int ix0
 * Return Type  : float
 */
float xnrm2(int n, const emxArray_real32_T *x, int ix0)
{
  const float *x_data;
  float y;
  int k;
  x_data = x->data;
  y = 0.0F;
  if (n >= 1) {
    if (n == 1) {
      y = fabsf(x_data[ix0 - 1]);
    } else {
      float scale;
      int kend;
      scale = 1.29246971E-26F;
      kend = (ix0 + n) - 1;
      for (k = ix0; k <= kend; k++) {
        float absxk;
        absxk = fabsf(x_data[k - 1]);
        if (absxk > scale) {
          float t;
          t = scale / absxk;
          y = y * t * t + 1.0F;
          scale = absxk;
        } else {
          float t;
          t = absxk / scale;
          y += t * t;
        }
      }
      y = scale * sqrtf(y);
    }
  }
  return y;
}

/*
 * File trailer for xnrm2.c
 *
 * [EOF]
 */
