/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: div.h
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

#ifndef DIV_H
#define DIV_H

/* Include Files */
#include "NEDwaves_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void b_binary_expand_op(emxArray_real_T *in1, const emxArray_real_T *in2,
                        const emxArray_real_T *in3);

void b_rdivide(emxArray_real_T *in1, const emxArray_real_T *in2);

void binary_expand_op(emxArray_real_T *in1, const emxArray_creal_T *in2,
                      const emxArray_real_T *in3);

void c_binary_expand_op(emxArray_real_T *in1, const emxArray_creal_T *in2);

void d_binary_expand_op(emxArray_real_T *in1, const emxArray_creal_T *in2,
                        const emxArray_real_T *in3);

void g_binary_expand_op(emxArray_real_T *in1, const emxArray_real_T *in2,
                        const emxArray_real_T *in3);

void rdivide(emxArray_real_T *in1, const emxArray_real_T *in2);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for div.h
 *
 * [EOF]
 */
