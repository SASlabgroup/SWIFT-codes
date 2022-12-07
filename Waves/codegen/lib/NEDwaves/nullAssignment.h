/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: nullAssignment.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

#ifndef NULLASSIGNMENT_H
#define NULLASSIGNMENT_H

/* Include Files */
#include "NEDwaves_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void b_nullAssignment(emxArray_creal32_T *x);

void c_nullAssignment(emxArray_real_T *x, const emxArray_boolean_T *idx);

void d_nullAssignment(emxArray_creal_T *x, const emxArray_boolean_T *idx);

void nullAssignment(emxArray_creal32_T *x, const emxArray_int32_T *idx);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for nullAssignment.h
 *
 * [EOF]
 */
