/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: mean.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

#ifndef MEAN_H
#define MEAN_H

/* Include Files */
#include "NEDwaves_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void b_mean(const emxArray_creal32_T *x, emxArray_creal32_T *y);

void c_mean(const emxArray_real_T *x, emxArray_real_T *y);

void d_mean(const emxArray_creal_T *x, emxArray_creal_T *y);

void mean(const emxArray_real32_T *x, emxArray_real32_T *y);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for mean.h
 *
 * [EOF]
 */
