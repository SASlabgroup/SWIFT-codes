/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: div.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 16-Oct-2023 17:01:43
 */

/* Include Files */
#include "div.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : float in1[42]
 *                const float in2[42]
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
void c_binary_expand_op(float in1[42], const float in2[42],
                        const emxArray_real_T *in3)
{
  const double *in3_data;
  int i;
  int stride_0_1;
  in3_data = in3->data;
  stride_0_1 = (in3->size[1] != 1);
  for (i = 0; i < 42; i++) {
    in1[i] = in2[i] / (float)in3_data[i * stride_0_1];
  }
}

/*
 * File trailer for div.c
 *
 * [EOF]
 */
