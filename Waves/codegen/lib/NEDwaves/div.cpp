//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// div.cpp
//
// Code generation for function 'div'
//

// Include files
#include "div.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
void b_binary_expand_op(coder::array<double, 2U> &in1,
                        const coder::array<double, 2U> &in2,
                        const coder::array<double, 2U> &in3)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in3.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in3.size(1);
  }
  in1.set_size(1, i);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in3.size(1) != 1);
  if (in3.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in3.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    in1[i] = in2[i * stride_0_1] / in3[i * stride_1_1];
  }
}

void b_binary_expand_op(coder::array<double, 2U> &in1,
                        const coder::array<creal_T, 2U> &in2,
                        const coder::array<double, 2U> &in3)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in3.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in3.size(1);
  }
  in1.set_size(1, i);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in3.size(1) != 1);
  if (in3.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in3.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    in1[i] = in2[i * stride_0_1].im / in3[i * stride_1_1];
  }
}

void b_rdivide(coder::array<double, 2U> &in1,
               const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in2;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in1.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in1.size(1);
  }
  b_in2.set_size(1, i);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in1.size(1) != 1);
  if (in1.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in1.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    b_in2[i] = in2[i * stride_0_1] / in1[i * stride_1_1];
  }
  in1.set_size(1, b_in2.size(1));
  loop_ub = b_in2.size(1);
  for (i = 0; i < loop_ub; i++) {
    in1[i] = b_in2[i];
  }
}

void binary_expand_op(coder::array<double, 2U> &in1,
                      const coder::array<creal_T, 2U> &in2)
{
  coder::array<double, 2U> b_in2;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in1.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in1.size(1);
  }
  b_in2.set_size(1, i);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in1.size(1) != 1);
  if (in1.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in1.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    b_in2[i] = in2[i * stride_0_1].im / in1[i * stride_1_1];
  }
  in1.set_size(1, b_in2.size(1));
  loop_ub = b_in2.size(1);
  for (i = 0; i < loop_ub; i++) {
    in1[i] = b_in2[i];
  }
}

void binary_expand_op(coder::array<double, 2U> &in1,
                      const coder::array<double, 2U> &in2,
                      const coder::array<double, 2U> &in3)
{
  coder::array<double, 2U> b_in1;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  int stride_2_1;
  if (in3.size(1) == 1) {
    if (in2.size(1) == 1) {
      i = in1.size(1);
    } else {
      i = in2.size(1);
    }
  } else {
    i = in3.size(1);
  }
  b_in1.set_size(1, i);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_1 = (in2.size(1) != 1);
  stride_2_1 = (in3.size(1) != 1);
  if (in3.size(1) == 1) {
    if (in2.size(1) == 1) {
      loop_ub = in1.size(1);
    } else {
      loop_ub = in2.size(1);
    }
  } else {
    loop_ub = in3.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1[i] =
        (in1[i * stride_0_1] - in2[i * stride_1_1]) / in3[i * stride_2_1];
  }
  in1.set_size(1, b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (i = 0; i < loop_ub; i++) {
    in1[i] = b_in1[i];
  }
}

void binary_expand_op(coder::array<double, 2U> &in1,
                      const coder::array<creal_T, 2U> &in2,
                      const coder::array<double, 2U> &in3)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in3.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in3.size(1);
  }
  in1.set_size(1, i);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in3.size(1) != 1);
  if (in3.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in3.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    in1[i] = 2.0 * in2[i * stride_0_1].re / in3[i * stride_1_1];
  }
}

void rdivide(coder::array<double, 2U> &in1, const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in1;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in2.size(1) == 1) {
    i = in1.size(1);
  } else {
    i = in2.size(1);
  }
  b_in1.set_size(1, i);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_1 = (in2.size(1) != 1);
  if (in2.size(1) == 1) {
    loop_ub = in1.size(1);
  } else {
    loop_ub = in2.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1[i] = in1[i * stride_0_1] / in2[i * stride_1_1];
  }
  in1.set_size(1, b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (i = 0; i < loop_ub; i++) {
    in1[i] = b_in1[i];
  }
}

// End of code generation (div.cpp)
