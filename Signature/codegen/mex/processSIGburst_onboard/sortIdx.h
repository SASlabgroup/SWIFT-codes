//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sortIdx.h
//
// Code generation for function 'sortIdx'
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
namespace internal {
void sortIdx(const emlrtStack &sp, ::coder::array<real_T, 1U> &x,
             ::coder::array<int32_T, 1U> &idx);

}
} // namespace coder

// End of code generation (sortIdx.h)
