/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves_memlight.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

#ifndef NEDWAVES_MEMLIGHT_H
#define NEDWAVES_MEMLIGHT_H

/* Include Files */
#include "NEDwaves_memlight_types.h"
#include "rtwhalf.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void NEDwaves_memlight(emxArray_real32_T *north, emxArray_real32_T *east,
                              emxArray_real32_T *down, double fs, real16_T *Hs,
                              real16_T *Tp, real16_T *Dp, real16_T E[42],
                              real16_T *b_fmin, real16_T *b_fmax,
                              signed char a1[42], signed char b1[42],
                              signed char a2[42], signed char b2[42],
                              unsigned char check[42]);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for NEDwaves_memlight.h
 *
 * [EOF]
 */
