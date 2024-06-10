//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// find.h
//
// Code generation for function 'find'
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
void eml_find(const emlrtStack &sp, const ::coder::array<boolean_T, 1U> &x,
              ::coder::array<int32_T, 1U> &i);

}

// End of code generation (find.h)
