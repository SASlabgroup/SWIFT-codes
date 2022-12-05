/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: std.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 05-Dec-2022 10:00:34
 */

/* Include Files */
#include "std.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "blockedSummation.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : const emxArray_real32_T *x
 * Return Type  : float
 */
float b_std(const emxArray_real32_T *x)
{
  emxArray_real32_T *absdiff;
  const float *x_data;
  float y;
  float *absdiff_data;
  int k;
  int n;
  x_data = x->data;
  n = x->size[0];
  if (x->size[0] == 0) {
    y = rtNaNF;
  } else if (x->size[0] == 1) {
    if ((!rtIsInfF(x_data[0])) && (!rtIsNaNF(x_data[0]))) {
      y = 0.0F;
    } else {
      y = rtNaNF;
    }
  } else {
    float xbar;
    int kend;
    emxInit_real32_T(&absdiff, 1);
    xbar = blockedSummation(x, x->size[0]) / (float)x->size[0];
    kend = absdiff->size[0];
    absdiff->size[0] = x->size[0];
    emxEnsureCapacity_real32_T(absdiff, kend);
    absdiff_data = absdiff->data;
    for (k = 0; k < n; k++) {
      absdiff_data[k] = fabsf(x_data[k] - xbar);
    }
    y = 0.0F;
    xbar = 1.29246971E-26F;
    kend = x->size[0];
    for (k = 0; k < kend; k++) {
      if (absdiff_data[k] > xbar) {
        float t;
        t = xbar / absdiff_data[k];
        y = y * t * t + 1.0F;
        xbar = absdiff_data[k];
      } else {
        float t;
        t = absdiff_data[k] / xbar;
        y += t * t;
      }
    }
    emxFree_real32_T(&absdiff);
    y = xbar * sqrtf(y) / sqrtf((float)(x->size[0] - 1));
  }
  return y;
}

/*
 * File trailer for std.c
 *
 * [EOF]
 */
