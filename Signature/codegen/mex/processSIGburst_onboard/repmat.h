//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// repmat.h
//
// Code generation for function 'repmat'
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
void repmat(const emlrtStack &sp, const ::coder::array<real_T, 2U> &a,
            real_T varargin_3, ::coder::array<real_T, 3U> &b);

}

// End of code generation (repmat.h)
