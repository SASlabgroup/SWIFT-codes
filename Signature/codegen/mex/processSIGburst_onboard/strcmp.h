//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// strcmp.h
//
// Code generation for function 'strcmp'
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
boolean_T b_strcmp(const ::coder::array<char_T, 2U> &a);

boolean_T c_strcmp(const ::coder::array<char_T, 2U> &a);

boolean_T d_strcmp(const ::coder::array<char_T, 2U> &a);

boolean_T e_strcmp(const ::coder::array<char_T, 2U> &a);

boolean_T f_strcmp(const ::coder::array<char_T, 2U> &a);

} // namespace internal
} // namespace coder

// End of code generation (strcmp.h)
