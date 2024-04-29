//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_SFdissipation_onboard_api.h
//
// Code generation for function 'SFdissipation_onboard'
//

#ifndef _CODER_SFDISSIPATION_ONBOARD_API_H
#define _CODER_SFDISSIPATION_ONBOARD_API_H

// Include files
#include "coder_array_mex.h"
#include "emlrt.h"
#include "tmwtypes.h"
#include <algorithm>
#include <cstring>

// Type Definitions
struct struct0_T {
  real_T mspe[128];
  real_T slope[128];
  real_T epserr[128];
  real_T A[128];
  real_T B[128];
  real_T N[128];
};

// Variable Declarations
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

// Function Declarations
void SFdissipation_onboard(coder::array<real_T, 2U> *w, real_T z[128],
                           real_T rmin, real_T rmax, real_T nzfit,
                           coder::array<char_T, 2U> *fittype,
                           coder::array<char_T, 2U> *avgtype, real_T eps[128],
                           struct0_T *qual);

void SFdissipation_onboard_api(const mxArray *const prhs[7], int32_T nlhs,
                               const mxArray *plhs[2]);

void SFdissipation_onboard_atexit();

void SFdissipation_onboard_initialize();

void SFdissipation_onboard_terminate();

void SFdissipation_onboard_xil_shutdown();

void SFdissipation_onboard_xil_terminate();

#endif
// End of code generation (_coder_SFdissipation_onboard_api.h)
