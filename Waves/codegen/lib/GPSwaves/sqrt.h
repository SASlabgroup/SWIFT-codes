/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: sqrt.h
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

#ifndef SQRT_H
#define SQRT_H

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
extern void b_sqrt(const emxArray_real_T *x, emxArray_real_T *b_x);
extern void c_sqrt(double *x);
extern void d_sqrt(emxArray_real_T *x);

#endif

/*
 * File trailer for sqrt.h
 *
 * [EOF]
 */
