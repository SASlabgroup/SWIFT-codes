//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// diff.h
//
// Code generation for function 'diff'
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
void diff(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
          ::coder::array<real_T, 2U> &y);

}

// End of code generation (diff.h)
