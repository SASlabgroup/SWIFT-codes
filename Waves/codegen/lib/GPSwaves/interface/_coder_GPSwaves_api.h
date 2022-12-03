/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_GPSwaves_api.h
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

#ifndef _CODER_GPSWAVES_API_H
#define _CODER_GPSWAVES_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_GPSwaves_api.h"

/* Type Definitions */
#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T

struct emxArray_real_T
{
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real_T*/

#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T

typedef struct emxArray_real_T emxArray_real_T;

#endif                                 /*typedef_emxArray_real_T*/

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void GPSwaves(emxArray_real_T *u, emxArray_real_T *v, emxArray_real_T *z,
                     real_T fs, real_T *Hs, real_T *Tp, real_T *Dp,
                     emxArray_real_T *E, emxArray_real_T *f, emxArray_real_T *a1,
                     emxArray_real_T *b1, emxArray_real_T *a2, emxArray_real_T
                     *b2);
extern void GPSwaves_api(const mxArray *prhs[4], const mxArray *plhs[9]);
extern void GPSwaves_atexit(void);
extern void GPSwaves_initialize(void);
extern void GPSwaves_terminate(void);
extern void GPSwaves_xil_terminate(void);

#endif

/*
 * File trailer for _coder_GPSwaves_api.h
 *
 * [EOF]
 */
