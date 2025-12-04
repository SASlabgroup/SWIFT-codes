/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: XYZaccelerationspectra.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 03-Dec-2025 20:33:49
 */

#ifndef XYZACCELERATIONSPECTRA_H
#define XYZACCELERATIONSPECTRA_H

/* Include Files */
#include "XYZaccelerationspectra_types.h"
#include "rtwhalf.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void XYZaccelerationspectra(const emxArray_real32_T *x,
                                   const emxArray_real32_T *y,
                                   const emxArray_real32_T *z, double fs,
                                   real16_T *b_fmin, real16_T *b_fmax,
                                   emxArray_real16_T *XX, emxArray_real16_T *YY,
                                   emxArray_real16_T *ZZ);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for XYZaccelerationspectra.h
 *
 * [EOF]
 */
