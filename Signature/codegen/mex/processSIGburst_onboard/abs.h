//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// abs.h
//
// Code generation for function 'abs'
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
void b_abs(const emlrtStack &sp, const ::coder::array<real_T, 3U> &x,
           ::coder::array<real_T, 3U> &y);

void b_abs(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
           ::coder::array<real_T, 2U> &y);

} // namespace coder

// End of code generation (abs.h)
