//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// movmedian.h
//
// Code generation for function 'movmedian'
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
void movmedian(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
               real_T k, ::coder::array<real_T, 2U> &y);

}

// End of code generation (movmedian.h)
