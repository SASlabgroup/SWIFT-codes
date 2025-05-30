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
void binary_expand_op(coder::array<double, 2U> &in1,
                      const coder::array<int, 2U> &in2)
{
  coder::array<double, 2U> b_in1;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in2.size(1) == 1) {
    loop_ub = in1.size(1);
  } else {
    loop_ub = in2.size(1);
  }
  b_in1.set_size(1, loop_ub);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_1 = (in2.size(1) != 1);
  for (int i = 0; i < loop_ub; i++) {
    b_in1[i] = in1[i * stride_0_1] / static_cast<double>(in2[i * stride_1_1]);
  }
  in1.set_size(1, b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (int i = 0; i < loop_ub; i++) {
    in1[i] = b_in1[i];
  }
}

void binary_expand_op(coder::array<double, 1U> &in1,
                      const coder::array<int, 1U> &in2)
{
  coder::array<double, 1U> b_in1;
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  if (in2.size(0) == 1) {
    loop_ub = in1.size(0);
  } else {
    loop_ub = in2.size(0);
  }
  b_in1.set_size(loop_ub);
  stride_0_0 = (in1.size(0) != 1);
  stride_1_0 = (in2.size(0) != 1);
  for (int i = 0; i < loop_ub; i++) {
    b_in1[i] = in1[i * stride_0_0] / static_cast<double>(in2[i * stride_1_0]);
  }
  in1.set_size(b_in1.size(0));
  loop_ub = b_in1.size(0);
  for (int i = 0; i < loop_ub; i++) {
    in1[i] = b_in1[i];
  }
}

// End of code generation (div.cpp)
