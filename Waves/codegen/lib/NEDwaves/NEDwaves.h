/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 05-Dec-2022 10:00:34
 */

#ifndef NEDWAVES_H
#define NEDWAVES_H

/* Include Files */
#include "NEDwaves_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void NEDwaves(emxArray_real32_T *north, emxArray_real32_T *east,
                     emxArray_real32_T *down, double fs, double *Hs, double *Tp,
                     double *Dp, emxArray_real_T *E, emxArray_real_T *f,
                     emxArray_real_T *a1, emxArray_real_T *b1,
                     emxArray_real_T *a2, emxArray_real_T *b2,
                     emxArray_real_T *check);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for NEDwaves.h
 *
 * [EOF]
 */
