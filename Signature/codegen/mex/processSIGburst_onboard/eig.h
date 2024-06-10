//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eig.h
//
// Code generation for function 'eig'
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
void eig(const emlrtStack &sp, const ::coder::array<real_T, 2U> &A,
         ::coder::array<creal_T, 2U> &V, ::coder::array<creal_T, 1U> &D);

}

// End of code generation (eig.h)
