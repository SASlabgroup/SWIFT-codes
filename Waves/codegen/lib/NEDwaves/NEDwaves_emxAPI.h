/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves_emxAPI.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

#ifndef NEDWAVES_EMXAPI_H
#define NEDWAVES_EMXAPI_H

/* Include Files */
#include "NEDwaves_types.h"
#include "rtwhalf.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern emxArray_int8_T *emxCreateND_int8_T(int numDimensions, const int *size);

extern emxArray_real16_T *emxCreateND_real16_T(int numDimensions,
                                               const int *size);

extern emxArray_real32_T *emxCreateND_real32_T(int numDimensions,
                                               const int *size);

extern emxArray_uint8_T *emxCreateND_uint8_T(int numDimensions,
                                             const int *size);

extern emxArray_int8_T *emxCreateWrapperND_int8_T(signed char *data,
                                                  int numDimensions,
                                                  const int *size);

extern emxArray_real16_T *
emxCreateWrapperND_real16_T(real16_T *data, int numDimensions, const int *size);

extern emxArray_real32_T *
emxCreateWrapperND_real32_T(float *data, int numDimensions, const int *size);

extern emxArray_uint8_T *emxCreateWrapperND_uint8_T(unsigned char *data,
                                                    int numDimensions,
                                                    const int *size);

extern emxArray_int8_T *emxCreateWrapper_int8_T(signed char *data, int rows,
                                                int cols);

extern emxArray_real16_T *emxCreateWrapper_real16_T(real16_T *data, int rows,
                                                    int cols);

extern emxArray_real32_T *emxCreateWrapper_real32_T(float *data, int rows,
                                                    int cols);

extern emxArray_uint8_T *emxCreateWrapper_uint8_T(unsigned char *data, int rows,
                                                  int cols);

extern emxArray_int8_T *emxCreate_int8_T(int rows, int cols);

extern emxArray_real16_T *emxCreate_real16_T(int rows, int cols);

extern emxArray_real32_T *emxCreate_real32_T(int rows, int cols);

extern emxArray_uint8_T *emxCreate_uint8_T(int rows, int cols);

extern void emxDestroyArray_int8_T(emxArray_int8_T *emxArray);

extern void emxDestroyArray_real16_T(emxArray_real16_T *emxArray);

extern void emxDestroyArray_real32_T(emxArray_real32_T *emxArray);

extern void emxDestroyArray_uint8_T(emxArray_uint8_T *emxArray);

extern void emxInitArray_int8_T(emxArray_int8_T **pEmxArray, int numDimensions);

extern void emxInitArray_real16_T(emxArray_real16_T **pEmxArray,
                                  int numDimensions);

extern void emxInitArray_real32_T(emxArray_real32_T **pEmxArray,
                                  int numDimensions);

extern void emxInitArray_uint8_T(emxArray_uint8_T **pEmxArray,
                                 int numDimensions);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for NEDwaves_emxAPI.h
 *
 * [EOF]
 */
