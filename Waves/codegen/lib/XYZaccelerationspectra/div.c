/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: div.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 11-Dec-2025 06:39:36
 */

/* Include Files */
#include "div.h"
#include "XYZaccelerationspectra_emxutil.h"
#include "XYZaccelerationspectra_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : emxArray_real32_T *in1
 *                const emxArray_creal32_T *in2
 *                const emxArray_creal32_T *in3
 *                double in4
 * Return Type  : void
 */
void binary_expand_op(emxArray_real32_T *in1, const emxArray_creal32_T *in2,
                      const emxArray_creal32_T *in3, double in4)
{
  const creal32_T *in2_data;
  const creal32_T *in3_data;
  float *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  if (in3->size[1] == 1) {
    in1->size[1] = in2->size[1];
  } else {
    in1->size[1] = in3->size[1];
  }
  emxEnsureCapacity_real32_T(in1, i);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    int in2_re_tmp;
    in2_re_tmp = i * stride_1_1;
    in1_data[i] = (in2_data[i * stride_0_1].re * in3_data[in2_re_tmp].re -
                   in2_data[i * stride_0_1].im * in3_data[in2_re_tmp].im) /
                  (float)in4;
  }
}

/*
 * File trailer for div.c
 *
 * [EOF]
 */
