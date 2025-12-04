/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_XYZaccelerationspectra_api.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 03-Dec-2025 20:33:49
 */

#ifndef _CODER_XYZACCELERATIONSPECTRA_API_H
#define _CODER_XYZACCELERATIONSPECTRA_API_H

/* Include Files */
#include "rtwhalf.h"
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Type Definitions */
#ifndef struct_emxArray_real32_T
#define struct_emxArray_real32_T
struct emxArray_real32_T {
  real32_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_real32_T */
#ifndef typedef_emxArray_real32_T
#define typedef_emxArray_real32_T
typedef struct emxArray_real32_T emxArray_real32_T;
#endif /* typedef_emxArray_real32_T */

#ifndef struct_emxArray_real16_T
#define struct_emxArray_real16_T
struct emxArray_real16_T {
  real16_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_real16_T */
#ifndef typedef_emxArray_real16_T
#define typedef_emxArray_real16_T
typedef struct emxArray_real16_T emxArray_real16_T;
#endif /* typedef_emxArray_real16_T */

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void XYZaccelerationspectra(emxArray_real32_T *x, emxArray_real32_T *y,
                            emxArray_real32_T *z, real_T fs, real16_T *b_fmin,
                            real16_T *b_fmax, emxArray_real16_T *XX,
                            emxArray_real16_T *YY, emxArray_real16_T *ZZ);

void XYZaccelerationspectra_api(const mxArray *const prhs[4], int32_T nlhs,
                                const mxArray *plhs[5]);

void XYZaccelerationspectra_atexit(void);

void XYZaccelerationspectra_initialize(void);

void XYZaccelerationspectra_terminate(void);

void XYZaccelerationspectra_xil_shutdown(void);

void XYZaccelerationspectra_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_XYZaccelerationspectra_api.h
 *
 * [EOF]
 */
