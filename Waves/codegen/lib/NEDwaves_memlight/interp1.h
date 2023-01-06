/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: interp1.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

#ifndef INTERP1_H
#define INTERP1_H

/* Include Files */
#include "NEDwaves_memlight_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void b_interp1(const emxArray_real_T *varargin_1,
               const emxArray_creal32_T *varargin_2, creal32_T Vq[42]);

void interp1(const emxArray_real_T *varargin_1,
             const emxArray_real32_T *varargin_2, float Vq[42]);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for interp1.h
 *
 * [EOF]
 */
