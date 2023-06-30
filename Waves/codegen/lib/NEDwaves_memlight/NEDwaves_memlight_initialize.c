/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: NEDwaves_memlight_initialize.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 30-Jun-2023 08:54:06
 */

/* Include Files */
#include "NEDwaves_memlight_initialize.h"
#include "NEDwaves_memlight_data.h"
#include "rt_nonfinite.h"
#include "omp.h"

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : void
 */
void NEDwaves_memlight_initialize(void)
{
  omp_init_nest_lock(&NEDwaves_memlight_nestLockGlobal);
  isInitialized_NEDwaves_memlight = true;
}

/*
 * File trailer for NEDwaves_memlight_initialize.c
 *
 * [EOF]
 */
