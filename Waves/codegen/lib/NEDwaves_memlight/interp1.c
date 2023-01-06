/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: interp1.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 06-Jan-2023 10:46:55
 */

/* Include Files */
#include "interp1.h"
#include "NEDwaves_memlight_data.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "bsearch.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *varargin_1
 *                const emxArray_creal32_T *varargin_2
 *                creal32_T Vq[42]
 * Return Type  : void
 */
void b_interp1(const emxArray_real_T *varargin_1,
               const emxArray_creal32_T *varargin_2, creal32_T Vq[42])
{
  emxArray_creal32_T *y;
  emxArray_real_T *x;
  const creal32_T *varargin_2_data;
  creal32_T *y_data;
  const double *varargin_1_data;
  double *x_data;
  int b_j1;
  int k;
  int nd2;
  int nx;
  varargin_2_data = varargin_2->data;
  varargin_1_data = varargin_1->data;
  emxInit_creal32_T(&y, 2);
  k = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = varargin_2->size[1];
  emxEnsureCapacity_creal32_T(y, k);
  y_data = y->data;
  nd2 = varargin_2->size[1];
  for (k = 0; k < nd2; k++) {
    y_data[k] = varargin_2_data[k];
  }
  emxInit_real_T(&x);
  k = x->size[0] * x->size[1];
  x->size[0] = 1;
  x->size[1] = varargin_1->size[1];
  emxEnsureCapacity_real_T(x, k);
  x_data = x->data;
  nd2 = varargin_1->size[1];
  for (k = 0; k < nd2; k++) {
    x_data[k] = varargin_1_data[k];
  }
  nx = varargin_1->size[1] - 1;
  k = 0;
  int exitg1;
  do {
    exitg1 = 0;
    if (k <= nx) {
      if (rtIsNaN(varargin_1_data[k])) {
        exitg1 = 1;
      } else {
        k++;
      }
    } else {
      double xtmp;
      float xtmp_im;
      float xtmp_re;
      if (varargin_1_data[1] < varargin_1_data[0]) {
        k = (nx + 1) >> 1;
        for (b_j1 = 0; b_j1 < k; b_j1++) {
          xtmp = x_data[b_j1];
          nd2 = nx - b_j1;
          x_data[b_j1] = x_data[nd2];
          x_data[nd2] = xtmp;
        }
        nd2 = varargin_2->size[1] >> 1;
        for (b_j1 = 0; b_j1 < nd2; b_j1++) {
          nx = (varargin_2->size[1] - b_j1) - 1;
          xtmp_re = y_data[b_j1].re;
          xtmp_im = y_data[b_j1].im;
          y_data[b_j1] = y_data[nx];
          y_data[nx].re = xtmp_re;
          y_data[nx].im = xtmp_im;
        }
      }
      for (k = 0; k < 42; k++) {
        Vq[k].re = rtNaNF;
        Vq[k].im = rtNaNF;
        xtmp = dv[k];
        if ((!(xtmp > x_data[x->size[1] - 1])) && (!(xtmp < x_data[0]))) {
          nd2 = b_bsearch(x, xtmp) - 1;
          xtmp = (xtmp - x_data[nd2]) / (x_data[nd2 + 1] - x_data[nd2]);
          if (xtmp == 0.0) {
            Vq[k] = y_data[nd2];
          } else if (xtmp == 1.0) {
            Vq[k] = y_data[nd2 + 1];
          } else {
            float b_y_tmp;
            float y_tmp;
            xtmp_re = y_data[nd2].re;
            xtmp_im = y_data[nd2 + 1].re;
            y_tmp = y_data[nd2].im;
            b_y_tmp = y_data[nd2 + 1].im;
            if ((xtmp_re == xtmp_im) && (y_tmp == b_y_tmp)) {
              Vq[k] = y_data[nd2];
            } else {
              Vq[k].re = (float)(1.0 - xtmp) * xtmp_re + (float)xtmp * xtmp_im;
              Vq[k].im = (float)(1.0 - xtmp) * y_tmp + (float)xtmp * b_y_tmp;
            }
          }
        }
      }
      exitg1 = 1;
    }
  } while (exitg1 == 0);
  emxFree_real_T(&x);
  emxFree_creal32_T(&y);
}

/*
 * Arguments    : const emxArray_real_T *varargin_1
 *                const emxArray_real32_T *varargin_2
 *                float Vq[42]
 * Return Type  : void
 */
void interp1(const emxArray_real_T *varargin_1,
             const emxArray_real32_T *varargin_2, float Vq[42])
{
  emxArray_real32_T *y;
  emxArray_real_T *x;
  const double *varargin_1_data;
  double *x_data;
  const float *varargin_2_data;
  float *y_data;
  int b_j1;
  int k;
  int nd2;
  int nx;
  varargin_2_data = varargin_2->data;
  varargin_1_data = varargin_1->data;
  emxInit_real32_T(&y, 2);
  k = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = varargin_2->size[1];
  emxEnsureCapacity_real32_T(y, k);
  y_data = y->data;
  nd2 = varargin_2->size[1];
  for (k = 0; k < nd2; k++) {
    y_data[k] = varargin_2_data[k];
  }
  emxInit_real_T(&x);
  k = x->size[0] * x->size[1];
  x->size[0] = 1;
  x->size[1] = varargin_1->size[1];
  emxEnsureCapacity_real_T(x, k);
  x_data = x->data;
  nd2 = varargin_1->size[1];
  for (k = 0; k < nd2; k++) {
    x_data[k] = varargin_1_data[k];
  }
  nx = varargin_1->size[1] - 1;
  k = 0;
  int exitg1;
  do {
    exitg1 = 0;
    if (k <= nx) {
      if (rtIsNaN(varargin_1_data[k])) {
        exitg1 = 1;
      } else {
        k++;
      }
    } else {
      double xtmp;
      if (varargin_1_data[1] < varargin_1_data[0]) {
        k = (nx + 1) >> 1;
        for (b_j1 = 0; b_j1 < k; b_j1++) {
          xtmp = x_data[b_j1];
          nd2 = nx - b_j1;
          x_data[b_j1] = x_data[nd2];
          x_data[nd2] = xtmp;
        }
        nd2 = varargin_2->size[1] >> 1;
        for (b_j1 = 0; b_j1 < nd2; b_j1++) {
          float b_xtmp;
          nx = (varargin_2->size[1] - b_j1) - 1;
          b_xtmp = y_data[b_j1];
          y_data[b_j1] = y_data[nx];
          y_data[nx] = b_xtmp;
        }
      }
      for (k = 0; k < 42; k++) {
        Vq[k] = rtNaNF;
        xtmp = dv[k];
        if ((!(xtmp > x_data[x->size[1] - 1])) && (!(xtmp < x_data[0]))) {
          nd2 = b_bsearch(x, xtmp) - 1;
          xtmp = (xtmp - x_data[nd2]) / (x_data[nd2 + 1] - x_data[nd2]);
          if (xtmp == 0.0) {
            Vq[k] = y_data[nd2];
          } else if (xtmp == 1.0) {
            Vq[k] = y_data[nd2 + 1];
          } else if (y_data[nd2] == y_data[nd2 + 1]) {
            Vq[k] = y_data[nd2];
          } else {
            Vq[k] = (float)(1.0 - xtmp) * y_data[nd2] +
                    (float)xtmp * y_data[nd2 + 1];
          }
        }
      }
      exitg1 = 1;
    }
  } while (exitg1 == 0);
  emxFree_real_T(&x);
  emxFree_real32_T(&y);
}

/*
 * File trailer for interp1.c
 *
 * [EOF]
 */
