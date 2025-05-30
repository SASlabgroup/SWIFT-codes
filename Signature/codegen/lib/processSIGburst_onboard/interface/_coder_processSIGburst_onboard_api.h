//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_processSIGburst_onboard_api.h
//
// Code generation for function 'processSIGburst_onboard'
//

#ifndef _CODER_PROCESSSIGBURST_ONBOARD_API_H
#define _CODER_PROCESSSIGBURST_ONBOARD_API_H

// Include files
#include "coder_array_mex.h"
#include "emlrt.h"
#include "tmwtypes.h"
#include <algorithm>
#include <cstring>

// Variable Declarations
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

// Function Declarations
void processSIGburst_onboard(coder::array<real_T, 2U> *wraw, real_T cs,
                             real_T dz, real_T bz, real_T neoflp, real_T rmin,
                             real_T rmax, real_T nzfit,
                             coder::array<char_T, 2U> *avgtype,
                             coder::array<char_T, 2U> *fittype,
                             coder::array<real_T, 2U> *eps);

void processSIGburst_onboard_api(const mxArray *const prhs[10],
                                 const mxArray **plhs);

void processSIGburst_onboard_atexit();

void processSIGburst_onboard_initialize();

void processSIGburst_onboard_terminate();

void processSIGburst_onboard_xil_shutdown();

void processSIGburst_onboard_xil_terminate();

#endif
// End of code generation (_coder_processSIGburst_onboard_api.h)
