/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: minOrMax.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 02-Sep-2023 15:57:28
 */

#ifndef MINORMAX_H
#define MINORMAX_H

/* Include Files */
#include "NEDwaves_memlight_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
double b_maximum(const emxArray_real_T *x);

double b_minimum(const emxArray_real_T *x);

void maximum(const float x[42], float *ex, int *idx);

void minimum(const emxArray_real32_T *x, float *ex, int *idx);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for minOrMax.h
 *
 * [EOF]
 */
