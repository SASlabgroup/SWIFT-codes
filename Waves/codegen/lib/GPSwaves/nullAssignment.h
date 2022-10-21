/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: nullAssignment.h
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

#ifndef NULLASSIGNMENT_H
#define NULLASSIGNMENT_H

/* Include Files */
#include <float.h>
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include "rtwtypes.h"
#include "GPSwaves_types.h"

/* Function Declarations */
extern void b_nullAssignment(emxArray_creal_T *x, const emxArray_int32_T *idx);
extern void c_nullAssignment(emxArray_creal_T *x);
extern void d_nullAssignment(emxArray_real_T *x, const emxArray_boolean_T *idx);
extern void nullAssignment(const emxArray_real_T *x, const emxArray_boolean_T
  *idx, emxArray_real_T *b_x);

#endif

/*
 * File trailer for nullAssignment.h
 *
 * [EOF]
 */
