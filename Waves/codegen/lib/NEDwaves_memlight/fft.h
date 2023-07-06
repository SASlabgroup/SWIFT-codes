/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: fft.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jul-2023 15:08:49
 */

#ifndef FFT_H
#define FFT_H

/* Include Files */
#include "NEDwaves_memlight_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void fft(const emxArray_real32_T *x, emxArray_creal32_T *y);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for fft.h
 *
 * [EOF]
 */
