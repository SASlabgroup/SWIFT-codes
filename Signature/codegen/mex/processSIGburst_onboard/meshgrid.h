//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// meshgrid.h
//
// Code generation for function 'meshgrid'
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
void meshgrid(const emlrtStack &sp, const ::coder::array<real_T, 2U> &x,
              ::coder::array<real_T, 2U> &xx, ::coder::array<real_T, 2U> &yy);

}

// End of code generation (meshgrid.h)
