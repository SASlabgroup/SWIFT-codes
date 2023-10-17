/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: var.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 16-Oct-2023 17:01:43
 */

/* Include Files */
#include "var.h"
#include "NEDwaves_memlight_types.h"
#include "combineVectorElements.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real32_T *x
 * Return Type  : float
 */
float var(const emxArray_real32_T *x)
{
  emxArray_real32_T c_x;
  const float *x_data;
  float y;
  int b_x;
  int d_x;
  int n;
  x_data = x->data;
  n = x->size[1];
  if (x->size[1] == 0) {
    y = rtNaNF;
  } else if (x->size[1] == 1) {
    if ((!rtIsInfF(x_data[0])) && (!rtIsNaNF(x_data[0]))) {
      y = 0.0F;
    } else {
      y = rtNaNF;
    }
  } else {
    float xbar;
    b_x = x->size[1];
    c_x = *x;
    d_x = b_x;
    c_x.size = &d_x;
    c_x.numDimensions = 1;
    xbar = combineVectorElements(&c_x, x->size[1]) / (float)x->size[1];
    y = 0.0F;
    for (b_x = 0; b_x < n; b_x++) {
      float t;
      t = x_data[b_x] - xbar;
      y += t * t;
    }
    y /= (float)(x->size[1] - 1);
  }
  return y;
}

/*
 * File trailer for var.c
 *
 * [EOF]
 */
