//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// div.h
//
// Code generation for function 'div'
//

#pragma once

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include "covrt.h"
#include "emlrt.h"
#include "mex.h"
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// Function Declarations
void b_binary_expand_op(const emlrtStack &sp, coder::array<real_T, 2U> &in1,
                        const coder::array<int32_T, 2U> &in2);

void rdivide(const emlrtStack &sp, coder::array<real_T, 1U> &in1,
             const coder::array<real_T, 1U> &in2);

void rdivide(const emlrtStack &sp, coder::array<real_T, 2U> &in1,
             const coder::array<real_T, 2U> &in2);

// End of code generation (div.h)
