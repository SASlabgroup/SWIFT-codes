//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard.h
//
// Code generation for function 'processSIGburst_onboard'
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
emlrtCTX emlrtGetRootTLSGlobal();

void emlrtLockerFunction(EmlrtLockeeFunction aLockee, emlrtConstCTX aTLS,
                         void *aData);

void processSIGburst_onboard(const emlrtStack *sp,
                             const coder::array<real_T, 2U> &wraw, real_T cs,
                             real_T dz, real_T bz, real_T neoflp, real_T rmin,
                             real_T rmax, real_T nzfit,
                             const coder::array<char_T, 2U> &avgtype,
                             const coder::array<char_T, 2U> &fittype,
                             coder::array<real_T, 2U> &eps);

// End of code generation (processSIGburst_onboard.h)
