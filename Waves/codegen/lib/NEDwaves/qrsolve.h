/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: qrsolve.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 05-Dec-2022 10:00:34
 */

#ifndef QRSOLVE_H
#define QRSOLVE_H

/* Include Files */
#include "NEDwaves_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void qrsolve(const emxArray_real32_T *A, const emxArray_real32_T *B, float Y[2],
             int *rankA);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for qrsolve.h
 *
 * [EOF]
 */
