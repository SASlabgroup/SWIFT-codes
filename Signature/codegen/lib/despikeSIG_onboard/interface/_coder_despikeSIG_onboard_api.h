//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_despikeSIG_onboard_api.h
//
// Code generation for function 'despikeSIG_onboard'
//

#ifndef _CODER_DESPIKESIG_ONBOARD_API_H
#define _CODER_DESPIKESIG_ONBOARD_API_H

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
void despikeSIG_onboard(coder::array<real_T, 2U> *wraw, real_T nfilt,
                        real_T dspikemax, coder::array<char_T, 2U> *filltype,
                        coder::array<real_T, 2U> *wclean,
                        coder::array<boolean_T, 2U> *ispike);

void despikeSIG_onboard_api(const mxArray *const prhs[4], int32_T nlhs,
                            const mxArray *plhs[2]);

void despikeSIG_onboard_atexit();

void despikeSIG_onboard_initialize();

void despikeSIG_onboard_terminate();

void despikeSIG_onboard_xil_shutdown();

void despikeSIG_onboard_xil_terminate();

#endif
// End of code generation (_coder_despikeSIG_onboard_api.h)
