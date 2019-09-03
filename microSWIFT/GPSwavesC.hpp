/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * GPSwaves.h
 *
 * Code generation for function 'GPSwaves'
 *
 */

#ifndef GPSWAVES_H
#define GPSWAVES_H

/* Include files */
#include <float.h>
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include "rtwtypes.h"
#include "GPSwaves_types.h"
#include "abs.h"

/* Function Declarations */
extern void GPSwaves(emxArray_real_T *u, emxArray_real_T *v, emxArray_real_T *z,
                     double fs, double *Hs, double *Tp, double *Dp,
                     emxArray_real_T *E, emxArray_real_T *f, emxArray_real_T *a1,
                     emxArray_real_T *b1, emxArray_real_T *a2, emxArray_real_T
                     *b2);

#endif

/* End of code generation (GPSwaves.h) */
