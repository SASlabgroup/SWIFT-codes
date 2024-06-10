//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// nanmean.h
//
// Code generation for function 'nanmean'
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
void nanmean(const emlrtStack &sp, coder::array<real_T, 2U> &x,
             coder::array<real_T, 2U> &m);

real_T nanmean(real_T x);

// End of code generation (nanmean.h)
