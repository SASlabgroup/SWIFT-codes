//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// combineVectorElements.h
//
// Code generation for function 'combineVectorElements'
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
int32_T b_combineVectorElements(const emlrtStack &sp,
                                const ::coder::array<boolean_T, 1U> &x);

void combineVectorElements(const emlrtStack &sp,
                           const ::coder::array<boolean_T, 2U> &x,
                           ::coder::array<int32_T, 2U> &y);

} // namespace coder

// End of code generation (combineVectorElements.h)
