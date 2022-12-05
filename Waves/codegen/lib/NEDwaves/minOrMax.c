/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: minOrMax.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 05-Dec-2022 10:00:34
 */

/* Include Files */
#include "minOrMax.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *x
 *                double *ex
 *                int *idx
 * Return Type  : void
 */
void maximum(const emxArray_real_T *x, double *ex, int *idx)
{
  const double *x_data;
  int k;
  int last;
  x_data = x->data;
  last = x->size[1];
  if (x->size[1] <= 2) {
    if (x->size[1] == 1) {
      *ex = x_data[0];
      *idx = 1;
    } else if ((x_data[0] < x_data[x->size[1] - 1]) ||
               (rtIsNaN(x_data[0]) && (!rtIsNaN(x_data[x->size[1] - 1])))) {
      *ex = x_data[x->size[1] - 1];
      *idx = x->size[1];
    } else {
      *ex = x_data[0];
      *idx = 1;
    }
  } else {
    if (!rtIsNaN(x_data[0])) {
      *idx = 1;
    } else {
      bool exitg1;
      *idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!rtIsNaN(x_data[k - 1])) {
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
        double d;
        d = x_data[k - 1];
        if (*ex < d) {
          *ex = d;
          *idx = k;
        }
      }
    }
  }
}

/*
 * Arguments    : const emxArray_real_T *x
 *                double *ex
 *                int *idx
 * Return Type  : void
 */
void minimum(const emxArray_real_T *x, double *ex, int *idx)
{
  const double *x_data;
  int k;
  int last;
  x_data = x->data;
  last = x->size[1];
  if (x->size[1] <= 2) {
    if (x->size[1] == 1) {
      *ex = x_data[0];
      *idx = 1;
    } else if ((x_data[0] > x_data[x->size[1] - 1]) ||
               (rtIsNaN(x_data[0]) && (!rtIsNaN(x_data[x->size[1] - 1])))) {
      *ex = x_data[x->size[1] - 1];
      *idx = x->size[1];
    } else {
      *ex = x_data[0];
      *idx = 1;
    }
  } else {
    if (!rtIsNaN(x_data[0])) {
      *idx = 1;
    } else {
      bool exitg1;
      *idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k <= last)) {
        if (!rtIsNaN(x_data[k - 1])) {
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
        double d;
        d = x_data[k - 1];
        if (*ex > d) {
          *ex = d;
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
