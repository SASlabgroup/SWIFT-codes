//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eml_mtimes_helper.h
//
// Code generation for function 'eml_mtimes_helper'
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
void dynamic_size_checks(const emlrtStack &sp,
                         const ::coder::array<real_T, 1U> &b, int32_T innerDimA,
                         int32_T innerDimB);

void dynamic_size_checks(const emlrtStack &sp,
                         const ::coder::array<creal_T, 2U> &a,
                         const ::coder::array<creal_T, 2U> &b,
                         int32_T innerDimA, int32_T innerDimB);

void dynamic_size_checks(const emlrtStack &sp,
                         const ::coder::array<real_T, 2U> &a,
                         const ::coder::array<creal_T, 2U> &b,
                         int32_T innerDimA, int32_T innerDimB);

void dynamic_size_checks(const emlrtStack &sp,
                         const ::coder::array<real_T, 2U> &a,
                         const ::coder::array<real_T, 2U> &b, int32_T innerDimA,
                         int32_T innerDimB);

} // namespace coder

// End of code generation (eml_mtimes_helper.h)
