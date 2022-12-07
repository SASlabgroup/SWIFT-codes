/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: div.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "div.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_real_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
void b_binary_expand_op(emxArray_real_T *in1, const emxArray_real_T *in2,
                        const emxArray_real_T *in3)
{
  emxArray_real_T *b_in1;
  const double *in2_data;
  const double *in3_data;
  double *b_in1_data;
  double *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  int stride_2_1;
  in3_data = in3->data;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_real_T(&b_in1, 2);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 1;
  if (in3->size[1] == 1) {
    if (in2->size[1] == 1) {
      b_in1->size[1] = in1->size[1];
    } else {
      b_in1->size[1] = in2->size[1];
    }
  } else {
    b_in1->size[1] = in3->size[1];
  }
  emxEnsureCapacity_real_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  stride_2_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    if (in2->size[1] == 1) {
      loop_ub = in1->size[1];
    } else {
      loop_ub = in2->size[1];
    }
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = (in1_data[i * stride_0_1] - in2_data[i * stride_1_1]) /
                    in3_data[i * stride_2_1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(&b_in1);
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_real_T *in2
 * Return Type  : void
 */
void b_rdivide(emxArray_real_T *in1, const emxArray_real_T *in2)
{
  emxArray_real_T *b_in2;
  const double *in2_data;
  double *b_in2_data;
  double *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_real_T(&b_in2, 2);
  i = b_in2->size[0] * b_in2->size[1];
  b_in2->size[0] = 1;
  if (in1->size[1] == 1) {
    b_in2->size[1] = in2->size[1];
  } else {
    b_in2->size[1] = in1->size[1];
  }
  emxEnsureCapacity_real_T(b_in2, i);
  b_in2_data = b_in2->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in1->size[1] != 1);
  if (in1->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in1->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    b_in2_data[i] = in2_data[i * stride_0_1] / in1_data[i * stride_1_1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in2->size[1];
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in2->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in2_data[i];
  }
  emxFree_real_T(&b_in2);
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_creal_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
void binary_expand_op(emxArray_real_T *in1, const emxArray_creal_T *in2,
                      const emxArray_real_T *in3)
{
  const creal_T *in2_data;
  const double *in3_data;
  double *in1_data;
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
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = 2.0 * in2_data[i * stride_0_1].re / in3_data[i * stride_1_1];
  }
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_creal_T *in2
 * Return Type  : void
 */
void c_binary_expand_op(emxArray_real_T *in1, const emxArray_creal_T *in2)
{
  emxArray_real_T *b_in2;
  const creal_T *in2_data;
  double *b_in2_data;
  double *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_real_T(&b_in2, 2);
  i = b_in2->size[0] * b_in2->size[1];
  b_in2->size[0] = 1;
  if (in1->size[1] == 1) {
    b_in2->size[1] = in2->size[1];
  } else {
    b_in2->size[1] = in1->size[1];
  }
  emxEnsureCapacity_real_T(b_in2, i);
  b_in2_data = b_in2->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in1->size[1] != 1);
  if (in1->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in1->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    b_in2_data[i] = in2_data[i * stride_0_1].im / in1_data[i * stride_1_1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in2->size[1];
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in2->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in2_data[i];
  }
  emxFree_real_T(&b_in2);
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_creal_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
void d_binary_expand_op(emxArray_real_T *in1, const emxArray_creal_T *in2,
                        const emxArray_real_T *in3)
{
  const creal_T *in2_data;
  const double *in3_data;
  double *in1_data;
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
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i * stride_0_1].im / in3_data[i * stride_1_1];
  }
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_real_T *in2
 *                const emxArray_real_T *in3
 * Return Type  : void
 */
void g_binary_expand_op(emxArray_real_T *in1, const emxArray_real_T *in2,
                        const emxArray_real_T *in3)
{
  const double *in2_data;
  const double *in3_data;
  double *in1_data;
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
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in3->size[1] != 1);
  if (in3->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in3->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = in2_data[i * stride_0_1] / in3_data[i * stride_1_1];
  }
}

/*
 * Arguments    : emxArray_real_T *in1
 *                const emxArray_real_T *in2
 * Return Type  : void
 */
void rdivide(emxArray_real_T *in1, const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const double *in2_data;
  double *b_in1_data;
  double *in1_data;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_real_T(&b_in1, 2);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 1;
  if (in2->size[1] == 1) {
    b_in1->size[1] = in1->size[1];
  } else {
    b_in1->size[1] = in2->size[1];
  }
  emxEnsureCapacity_real_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] = in1_data[i * stride_0_1] / in2_data[i * stride_1_1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 1;
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_real_T(&b_in1);
}

/*
 * File trailer for div.c
 *
 * [EOF]
 */
