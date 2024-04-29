//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_eof_api.h
//
// Code generation for function 'eof'
//

#ifndef _CODER_EOF_API_H
#define _CODER_EOF_API_H

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
void eof(coder::array<real_T, 2U> *X, coder::array<creal_T, 2U> *EOFs,
         coder::array<creal_T, 2U> *alpha, coder::array<creal_T, 2U> *E,
         coder::array<real_T, 2U> *Xm);

void eof_api(const mxArray *prhs, int32_T nlhs, const mxArray *plhs[4]);

void eof_atexit();

void eof_initialize();

void eof_terminate();

void eof_xil_shutdown();

void eof_xil_terminate();

#endif
// End of code generation (_coder_eof_api.h)
