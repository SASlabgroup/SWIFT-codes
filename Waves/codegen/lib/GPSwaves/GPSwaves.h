/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: GPSwaves.h
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

#ifndef GPSWAVES_H
#define GPSWAVES_H

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
extern void GPSwaves(emxArray_real_T *u, emxArray_real_T *v, emxArray_real_T *z,
                     double fs, double *Hs, double *Tp, double *Dp,
                     emxArray_real_T *E, emxArray_real_T *f, emxArray_real_T *a1,
                     emxArray_real_T *b1, emxArray_real_T *a2, emxArray_real_T
                     *b2);

#endif

/*
 * File trailer for GPSwaves.h
 *
 * [EOF]
 */
