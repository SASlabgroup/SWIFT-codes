/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: mean.h
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

#ifndef MEAN_H
#define MEAN_H

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
extern void b_mean(const emxArray_real_T *x, emxArray_real_T *y);
extern void c_mean(const emxArray_creal_T *x, emxArray_creal_T *y);
extern double mean(const emxArray_real_T *x);

#endif

/*
 * File trailer for mean.h
 *
 * [EOF]
 */
