/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: FFTImplementationCallback.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jul-2023 15:08:49
 */

#ifndef FFTIMPLEMENTATIONCALLBACK_H
#define FFTIMPLEMENTATIONCALLBACK_H

/* Include Files */
#include "NEDwaves_memlight_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void c_FFTImplementationCallback_doH(const emxArray_real32_T *x,
                                     emxArray_creal32_T *y, int unsigned_nRows,
                                     const emxArray_real32_T *costab,
                                     const emxArray_real32_T *sintab);

void c_FFTImplementationCallback_dob(const emxArray_real32_T *x, int n2blue,
                                     int nfft, const emxArray_real32_T *costab,
                                     const emxArray_real32_T *sintab,
                                     const emxArray_real32_T *sintabinv,
                                     emxArray_creal32_T *y);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for FFTImplementationCallback.h
 *
 * [EOF]
 */
