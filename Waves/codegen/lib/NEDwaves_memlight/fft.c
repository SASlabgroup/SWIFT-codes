/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: fft.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

/* Include Files */
#include "fft.h"
#include "FFTImplementationCallback.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : const emxArray_real32_T *x
 *                emxArray_creal32_T *y
 * Return Type  : void
 */
void fft(const emxArray_real32_T *x, emxArray_creal32_T *y)
{
  emxArray_creal32_T *yCol;
  emxArray_real32_T b_x;
  emxArray_real32_T *costab;
  emxArray_real32_T *costab1q;
  emxArray_real32_T *sintab;
  emxArray_real32_T *sintabinv;
  creal32_T *yCol_data;
  creal32_T *y_data;
  const float *x_data;
  float *costab1q_data;
  float *costab_data;
  float *sintab_data;
  float *sintabinv_data;
  int c_x;
  int d_x;
  int k;
  int pow2p;
  x_data = x->data;
  if (x->size[1] == 0) {
    y->size[0] = 1;
    y->size[1] = 0;
  } else {
    float e;
    int n;
    int pmax;
    int pmin;
    bool useRadix2;
    useRadix2 = ((x->size[1] & (x->size[1] - 1)) == 0);
    pmin = 1;
    if (useRadix2) {
      pmax = x->size[1];
    } else {
      n = (x->size[1] + x->size[1]) - 1;
      pmax = 31;
      if (n <= 1) {
        pmax = 0;
      } else {
        bool exitg1;
        pmin = 0;
        exitg1 = false;
        while ((!exitg1) && (pmax - pmin > 1)) {
          k = (pmin + pmax) >> 1;
          pow2p = 1 << k;
          if (pow2p == n) {
            pmax = k;
            exitg1 = true;
          } else if (pow2p > n) {
            pmax = k;
          } else {
            pmin = k;
          }
        }
      }
      pmin = 1 << pmax;
      pmax = pmin;
    }
    emxInit_real32_T(&costab1q, 2);
    e = 6.28318548F / (float)pmax;
    n = pmax / 2 / 2;
    pow2p = costab1q->size[0] * costab1q->size[1];
    costab1q->size[0] = 1;
    costab1q->size[1] = n + 1;
    emxEnsureCapacity_real32_T(costab1q, pow2p);
    costab1q_data = costab1q->data;
    costab1q_data[0] = 1.0F;
    pmax = n / 2 - 1;
    for (k = 0; k <= pmax; k++) {
      costab1q_data[k + 1] = cosf(e * (float)(k + 1));
    }
    pow2p = pmax + 2;
    pmax = n - 1;
    for (k = pow2p; k <= pmax; k++) {
      costab1q_data[k] = sinf(e * (float)(n - k));
    }
    costab1q_data[n] = 0.0F;
    emxInit_real32_T(&costab, 2);
    emxInit_real32_T(&sintab, 2);
    emxInit_real32_T(&sintabinv, 2);
    if (!useRadix2) {
      n = costab1q->size[1] - 1;
      pmax = (costab1q->size[1] - 1) << 1;
      pow2p = costab->size[0] * costab->size[1];
      costab->size[0] = 1;
      costab->size[1] = pmax + 1;
      emxEnsureCapacity_real32_T(costab, pow2p);
      costab_data = costab->data;
      pow2p = sintab->size[0] * sintab->size[1];
      sintab->size[0] = 1;
      sintab->size[1] = pmax + 1;
      emxEnsureCapacity_real32_T(sintab, pow2p);
      sintab_data = sintab->data;
      costab_data[0] = 1.0F;
      sintab_data[0] = 0.0F;
      pow2p = sintabinv->size[0] * sintabinv->size[1];
      sintabinv->size[0] = 1;
      sintabinv->size[1] = pmax + 1;
      emxEnsureCapacity_real32_T(sintabinv, pow2p);
      sintabinv_data = sintabinv->data;
      for (k = 0; k < n; k++) {
        sintabinv_data[k + 1] = costab1q_data[(n - k) - 1];
      }
      pow2p = costab1q->size[1];
      for (k = pow2p; k <= pmax; k++) {
        sintabinv_data[k] = costab1q_data[k - n];
      }
      for (k = 0; k < n; k++) {
        costab_data[k + 1] = costab1q_data[k + 1];
        sintab_data[k + 1] = -costab1q_data[(n - k) - 1];
      }
      pow2p = costab1q->size[1];
      for (k = pow2p; k <= pmax; k++) {
        costab_data[k] = -costab1q_data[pmax - k];
        sintab_data[k] = -costab1q_data[k - n];
      }
    } else {
      n = costab1q->size[1] - 1;
      pmax = (costab1q->size[1] - 1) << 1;
      pow2p = costab->size[0] * costab->size[1];
      costab->size[0] = 1;
      costab->size[1] = pmax + 1;
      emxEnsureCapacity_real32_T(costab, pow2p);
      costab_data = costab->data;
      pow2p = sintab->size[0] * sintab->size[1];
      sintab->size[0] = 1;
      sintab->size[1] = pmax + 1;
      emxEnsureCapacity_real32_T(sintab, pow2p);
      sintab_data = sintab->data;
      costab_data[0] = 1.0F;
      sintab_data[0] = 0.0F;
      for (k = 0; k < n; k++) {
        costab_data[k + 1] = costab1q_data[k + 1];
        sintab_data[k + 1] = -costab1q_data[(n - k) - 1];
      }
      pow2p = costab1q->size[1];
      for (k = pow2p; k <= pmax; k++) {
        costab_data[k] = -costab1q_data[pmax - k];
        sintab_data[k] = -costab1q_data[k - n];
      }
      sintabinv->size[0] = 1;
      sintabinv->size[1] = 0;
    }
    emxFree_real32_T(&costab1q);
    emxInit_creal32_T(&yCol, 1);
    if (useRadix2) {
      pow2p = yCol->size[0];
      yCol->size[0] = x->size[1];
      emxEnsureCapacity_creal32_T(yCol, pow2p);
      yCol_data = yCol->data;
      if (x->size[1] != 1) {
        pmax = x->size[1];
        b_x = *x;
        d_x = pmax;
        b_x.size = &d_x;
        b_x.numDimensions = 1;
        c_FFTImplementationCallback_doH(&b_x, yCol, x->size[1], costab, sintab);
        yCol_data = yCol->data;
      } else {
        yCol_data[0].re = x_data[0];
        yCol_data[0].im = 0.0F;
      }
    } else {
      pmax = x->size[1];
      b_x = *x;
      c_x = pmax;
      b_x.size = &c_x;
      b_x.numDimensions = 1;
      c_FFTImplementationCallback_dob(&b_x, pmin, x->size[1], costab, sintab,
                                      sintabinv, yCol);
      yCol_data = yCol->data;
    }
    emxFree_real32_T(&sintabinv);
    emxFree_real32_T(&sintab);
    emxFree_real32_T(&costab);
    pow2p = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = x->size[1];
    emxEnsureCapacity_creal32_T(y, pow2p);
    y_data = y->data;
    pmax = x->size[1];
    for (pow2p = 0; pow2p < pmax; pow2p++) {
      y_data[pow2p] = yCol_data[pow2p];
    }
    emxFree_creal32_T(&yCol);
  }
}

/*
 * File trailer for fft.c
 *
 * [EOF]
 */
