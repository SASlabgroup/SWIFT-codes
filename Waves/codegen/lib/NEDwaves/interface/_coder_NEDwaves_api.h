//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_NEDwaves_api.h
//
// Code generation for function 'NEDwaves'
//

#ifndef _CODER_NEDWAVES_API_H
#define _CODER_NEDWAVES_API_H

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
void NEDwaves(coder::array<real32_T, 1U> *north,
              coder::array<real32_T, 1U> *east,
              coder::array<real32_T, 1U> *down, real_T fs, real_T *Hs,
              real_T *Tp, real_T *Dp, coder::array<real_T, 2U> *E,
              coder::array<real_T, 2U> *f, coder::array<real_T, 2U> *a1,
              coder::array<real_T, 2U> *b1, coder::array<real_T, 2U> *a2,
              coder::array<real_T, 2U> *b2, coder::array<real_T, 2U> *check);

void NEDwaves_api(const mxArray *const prhs[4], int32_T nlhs,
                  const mxArray *plhs[10]);

void NEDwaves_atexit();

void NEDwaves_initialize();

void NEDwaves_terminate();

void NEDwaves_xil_shutdown();

void NEDwaves_xil_terminate();

#endif
// End of code generation (_coder_NEDwaves_api.h)
