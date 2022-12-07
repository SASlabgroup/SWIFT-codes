/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_NEDwaves_api.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

#ifndef _CODER_NEDWAVES_API_H
#define _CODER_NEDWAVES_API_H

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

#ifndef struct_emxArray_int8_T
#define struct_emxArray_int8_T
struct emxArray_int8_T {
  int8_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_int8_T */
#ifndef typedef_emxArray_int8_T
#define typedef_emxArray_int8_T
typedef struct emxArray_int8_T emxArray_int8_T;
#endif /* typedef_emxArray_int8_T */

#ifndef struct_emxArray_uint8_T
#define struct_emxArray_uint8_T
struct emxArray_uint8_T {
  uint8_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_uint8_T */
#ifndef typedef_emxArray_uint8_T
#define typedef_emxArray_uint8_T
typedef struct emxArray_uint8_T emxArray_uint8_T;
#endif /* typedef_emxArray_uint8_T */

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void NEDwaves(emxArray_real32_T *north, emxArray_real32_T *east,
              emxArray_real32_T *down, real_T fs, real16_T *Hs, real16_T *Tp,
              real16_T *Dp, emxArray_real16_T *E, real16_T *b_fmin,
              real16_T *b_fmax, emxArray_int8_T *a1, emxArray_int8_T *b1,
              emxArray_int8_T *a2, emxArray_int8_T *b2,
              emxArray_uint8_T *check);

void NEDwaves_api(const mxArray *const prhs[4], int32_T nlhs,
                  const mxArray *plhs[11]);

void NEDwaves_atexit(void);

void NEDwaves_initialize(void);

void NEDwaves_terminate(void);

void NEDwaves_xil_shutdown(void);

void NEDwaves_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_NEDwaves_api.h
 *
 * [EOF]
 */
