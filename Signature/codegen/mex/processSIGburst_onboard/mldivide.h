//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mldivide.h
//
// Code generation for function 'mldivide'
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
namespace coder {
void b_mldivide(const emlrtStack &sp, const real_T A[4],
                const ::coder::array<real_T, 2U> &B,
                ::coder::array<real_T, 2U> &Y);

void mldivide(const emlrtStack &sp, const real_T A[9],
              const ::coder::array<real_T, 2U> &B,
              ::coder::array<real_T, 2U> &Y);

} // namespace coder

// End of code generation (mldivide.h)
