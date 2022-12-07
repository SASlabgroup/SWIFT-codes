/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

#ifndef NEDWAVES_H
#define NEDWAVES_H

/* Include Files */
#include "NEDwaves_types.h"
#include "rtwhalf.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void NEDwaves(emxArray_real32_T *north, emxArray_real32_T *east,
                     emxArray_real32_T *down, double fs, real16_T *Hs,
                     real16_T *Tp, real16_T *Dp, emxArray_real16_T *E,
                     real16_T *b_fmin, real16_T *b_fmax, emxArray_int8_T *a1,
                     emxArray_int8_T *b1, emxArray_int8_T *a2,
                     emxArray_int8_T *b2, emxArray_uint8_T *check);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for NEDwaves.h
 *
 * [EOF]
 */
