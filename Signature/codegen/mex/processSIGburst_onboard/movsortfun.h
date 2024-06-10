//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// movsortfun.h
//
// Code generation for function 'movsortfun'
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
void movsortfun(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
                int32_T kleft, int32_T kright, ::coder::array<real_T, 2U> &y);

}

// End of code generation (movsortfun.h)
