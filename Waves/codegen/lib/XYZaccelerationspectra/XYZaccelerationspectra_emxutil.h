/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: XYZaccelerationspectra_emxutil.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 03-Dec-2025 20:33:49
 */

#ifndef XYZACCELERATIONSPECTRA_EMXUTIL_H
#define XYZACCELERATIONSPECTRA_EMXUTIL_H

/* Include Files */
#include "XYZaccelerationspectra_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void emxEnsureCapacity_boolean_T(emxArray_boolean_T *emxArray,
                                        int oldNumel);

extern void emxEnsureCapacity_creal32_T(emxArray_creal32_T *emxArray,
                                        int oldNumel);

extern void emxEnsureCapacity_int32_T(emxArray_int32_T *emxArray, int oldNumel);

extern void emxEnsureCapacity_real16_T(emxArray_real16_T *emxArray,
                                       int oldNumel);

extern void emxEnsureCapacity_real32_T(emxArray_real32_T *emxArray,
                                       int oldNumel);

extern void emxEnsureCapacity_real_T(emxArray_real_T *emxArray, int oldNumel);

extern void emxFree_boolean_T(emxArray_boolean_T **pEmxArray);

extern void emxFree_creal32_T(emxArray_creal32_T **pEmxArray);

extern void emxFree_int32_T(emxArray_int32_T **pEmxArray);

extern void emxFree_real16_T(emxArray_real16_T **pEmxArray);

extern void emxFree_real32_T(emxArray_real32_T **pEmxArray);

extern void emxFree_real_T(emxArray_real_T **pEmxArray);

extern void emxInit_boolean_T(emxArray_boolean_T **pEmxArray);

extern void emxInit_creal32_T(emxArray_creal32_T **pEmxArray,
                              int numDimensions);

extern void emxInit_int32_T(emxArray_int32_T **pEmxArray, int numDimensions);

extern void emxInit_real16_T(emxArray_real16_T **pEmxArray, int numDimensions);

extern void emxInit_real32_T(emxArray_real32_T **pEmxArray, int numDimensions);

extern void emxInit_real_T(emxArray_real_T **pEmxArray);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for XYZaccelerationspectra_emxutil.h
 *
 * [EOF]
 */
