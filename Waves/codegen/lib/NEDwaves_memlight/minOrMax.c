/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: minOrMax.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 30-Jun-2023 08:54:06
 */

/* Include Files */
#include "minOrMax.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *x
 * Return Type  : double
 */
double b_maximum(const emxArray_real_T *x)
{
  const double *x_data;
  double ex;
  int k;
  int last;
  x_data = x->data;
  last = x->size[1];
  if (x->size[1] <= 2) {
    if (x->size[1] == 1) {
      ex = x_data[0];
    } else if ((x_data[0] < x_data[x->size[1] - 1]) ||
               (rtIsNaN(x_data[0]) && (!rtIsNaN(x_data[x->size[1] - 1])))) {
      ex = x_data[x->size[1] - 1];
    } else {
      ex = x_data[0];
    }
  } else {
    int idx;
    if (!rtIsNaN(x_data[0])) {
      idx = 1;
    } else {
      bool exitg1;
      idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!rtIsNaN(x_data[k - 1])) {
          idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (idx == 0) {
      ex = x_data[0];
    } else {
      ex = x_data[idx - 1];
      idx++;
      for (k = idx; k <= last; k++) {
        double d;
        d = x_data[k - 1];
        if (ex < d) {
          ex = d;
        }
      }
    }
  }
  return ex;
}

/*
 * Arguments    : const emxArray_real_T *x
 * Return Type  : double
 */
double b_minimum(const emxArray_real_T *x)
{
  const double *x_data;
  double ex;
  int k;
  int last;
  x_data = x->data;
  last = x->size[1];
  if (x->size[1] <= 2) {
    if (x->size[1] == 1) {
      ex = x_data[0];
    } else if ((x_data[0] > x_data[x->size[1] - 1]) ||
               (rtIsNaN(x_data[0]) && (!rtIsNaN(x_data[x->size[1] - 1])))) {
      ex = x_data[x->size[1] - 1];
    } else {
      ex = x_data[0];
    }
  } else {
    int idx;
    if (!rtIsNaN(x_data[0])) {
      idx = 1;
    } else {
      bool exitg1;
      idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!rtIsNaN(x_data[k - 1])) {
          idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (idx == 0) {
      ex = x_data[0];
    } else {
      ex = x_data[idx - 1];
      idx++;
      for (k = idx; k <= last; k++) {
        double d;
        d = x_data[k - 1];
        if (ex > d) {
          ex = d;
        }
      }
    }
  }
  return ex;
}

/*
 * Arguments    : const float x[42]
 *                float *ex
 *                int *idx
 * Return Type  : void
 */
void maximum(const float x[42], float *ex, int *idx)
{
  int k;
  if (!rtIsNaNF(x[0])) {
    *idx = 1;
  } else {
    bool exitg1;
    *idx = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 43)) {
      if (!rtIsNaNF(x[k - 1])) {
        *idx = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }
  if (*idx == 0) {
    *ex = x[0];
    *idx = 1;
  } else {
    int i;
    *ex = x[*idx - 1];
    i = *idx + 1;
    for (k = i; k < 43; k++) {
      float f;
      f = x[k - 1];
      if (*ex < f) {
        *ex = f;
        *idx = k;
      }
    }
  }
}

/*
 * Arguments    : const emxArray_real32_T *x
 *                float *ex
 *                int *idx
 * Return Type  : void
 */
void minimum(const emxArray_real32_T *x, float *ex, int *idx)
{
  const float *x_data;
  int k;
  int last;
  x_data = x->data;
  last = x->size[1];
  if (x->size[1] <= 2) {
    if (x->size[1] == 1) {
      *ex = x_data[0];
      *idx = 1;
    } else if ((x_data[0] > x_data[x->size[1] - 1]) ||
               (rtIsNaNF(x_data[0]) && (!rtIsNaNF(x_data[x->size[1] - 1])))) {
      *ex = x_data[x->size[1] - 1];
      *idx = x->size[1];
    } else {
      *ex = x_data[0];
      *idx = 1;
    }
  } else {
    if (!rtIsNaNF(x_data[0])) {
      *idx = 1;
    } else {
      bool exitg1;
      *idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!rtIsNaNF(x_data[k - 1])) {
          *idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (*idx == 0) {
      *ex = x_data[0];
      *idx = 1;
    } else {
      int i;
      *ex = x_data[*idx - 1];
      i = *idx + 1;
      for (k = i; k <= last; k++) {
        float f;
        f = x_data[k - 1];
        if (*ex > f) {
          *ex = f;
          *idx = k;
        }
      }
    }
  }
}

/*
 * File trailer for minOrMax.c
 *
 * [EOF]
 */
