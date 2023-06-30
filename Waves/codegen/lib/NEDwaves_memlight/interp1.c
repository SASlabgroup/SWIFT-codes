/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: interp1.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 30-Jun-2023 08:54:06
 */

/* Include Files */
#include "interp1.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"
#include "omp.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static void interp1Linear(const emxArray_creal32_T *y,
                          const emxArray_real_T *xi, emxArray_creal32_T *yi,
                          const emxArray_real_T *varargin_1);

/* Function Definitions */
/*
 * Arguments    : const emxArray_creal32_T *y
 *                const emxArray_real_T *xi
 *                emxArray_creal32_T *yi
 *                const emxArray_real_T *varargin_1
 * Return Type  : void
 */
static void interp1Linear(const emxArray_creal32_T *y,
                          const emxArray_real_T *xi, emxArray_creal32_T *yi,
                          const emxArray_real_T *varargin_1)
{
  const creal32_T *y_data;
  creal32_T *yi_data;
  const double *varargin_1_data;
  const double *xi_data;
  double maxx;
  double minx;
  double r;
  float b_y_tmp;
  float y1_im;
  float y1_re;
  float y_tmp;
  int high_i;
  int k;
  int low_i;
  int low_ip1;
  int mid_i;
  int ub_loop;
  varargin_1_data = varargin_1->data;
  yi_data = yi->data;
  xi_data = xi->data;
  y_data = y->data;
  minx = varargin_1_data[0];
  maxx = varargin_1_data[varargin_1->size[1] - 1];
  ub_loop = xi->size[1] - 1;
#pragma omp parallel for num_threads(omp_get_max_threads()) private(           \
    y1_re, y1_im, r, high_i, low_i, low_ip1, mid_i, y_tmp, b_y_tmp)

  for (k = 0; k <= ub_loop; k++) {
    y1_re = yi_data[k].re;
    y1_im = yi_data[k].im;
    r = xi_data[k];
    if (rtIsNaN(r)) {
      y1_re = rtNaNF;
      y1_im = rtNaNF;
    } else if ((!(r > maxx)) && (!(r < minx))) {
      high_i = varargin_1->size[1];
      low_i = 1;
      low_ip1 = 2;
      while (high_i > low_ip1) {
        mid_i = (low_i >> 1) + (high_i >> 1);
        if (((low_i & 1) == 1) && ((high_i & 1) == 1)) {
          mid_i++;
        }
        if (xi_data[k] >= varargin_1_data[mid_i - 1]) {
          low_i = mid_i;
          low_ip1 = mid_i + 1;
        } else {
          high_i = mid_i;
        }
      }
      r = varargin_1_data[low_i - 1];
      r = (xi_data[k] - r) / (varargin_1_data[low_i] - r);
      if (r == 0.0) {
        y1_re = y_data[low_i - 1].re;
        y1_im = y_data[low_i - 1].im;
      } else if (r == 1.0) {
        y1_re = y_data[low_i].re;
        y1_im = y_data[low_i].im;
      } else {
        y1_re = y_data[low_i - 1].re;
        y1_im = y_data[low_i - 1].im;
        y_tmp = y_data[low_i].re;
        b_y_tmp = y_data[low_i].im;
        if ((!(y1_re == y_tmp)) || (!(y1_im == b_y_tmp))) {
          y1_re = (float)(1.0 - r) * y1_re + (float)r * y_tmp;
          y1_im = (float)(1.0 - r) * y1_im + (float)r * b_y_tmp;
        }
      }
    }
    yi_data[k].re = y1_re;
    yi_data[k].im = y1_im;
  }
}

/*
 * Arguments    : const emxArray_real_T *varargin_1
 *                const emxArray_creal32_T *varargin_2
 *                const emxArray_real_T *varargin_3
 *                emxArray_creal32_T *Vq
 * Return Type  : void
 */
void interp1(const emxArray_real_T *varargin_1,
             const emxArray_creal32_T *varargin_2,
             const emxArray_real_T *varargin_3, emxArray_creal32_T *Vq)
{
  emxArray_creal32_T *y;
  emxArray_real_T *x;
  const creal32_T *varargin_2_data;
  creal32_T *Vq_data;
  creal32_T *y_data;
  const double *varargin_1_data;
  double *x_data;
  int b_j1;
  int i;
  int nd2;
  int nx;
  bool b;
  varargin_2_data = varargin_2->data;
  varargin_1_data = varargin_1->data;
  emxInit_creal32_T(&y, 2);
  i = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = varargin_2->size[1];
  emxEnsureCapacity_creal32_T(y, i);
  y_data = y->data;
  nd2 = varargin_2->size[1];
  for (i = 0; i < nd2; i++) {
    y_data[i] = varargin_2_data[i];
  }
  emxInit_real_T(&x, 2);
  i = x->size[0] * x->size[1];
  x->size[0] = 1;
  x->size[1] = varargin_1->size[1];
  emxEnsureCapacity_real_T(x, i);
  x_data = x->data;
  nd2 = varargin_1->size[1];
  for (i = 0; i < nd2; i++) {
    x_data[i] = varargin_1_data[i];
  }
  nx = varargin_1->size[1] - 1;
  i = Vq->size[0] * Vq->size[1];
  Vq->size[0] = 1;
  Vq->size[1] = varargin_3->size[1];
  emxEnsureCapacity_creal32_T(Vq, i);
  Vq_data = Vq->data;
  nd2 = varargin_3->size[1];
  for (i = 0; i < nd2; i++) {
    Vq_data[i].re = rtNaNF;
    Vq_data[i].im = rtNaNF;
  }
  b = (varargin_3->size[1] == 0);
  if (!b) {
    nd2 = 0;
    int exitg1;
    do {
      exitg1 = 0;
      if (nd2 <= nx) {
        if (rtIsNaN(varargin_1_data[nd2])) {
          exitg1 = 1;
        } else {
          nd2++;
        }
      } else {
        if (varargin_1_data[1] < varargin_1_data[0]) {
          i = (nx + 1) >> 1;
          for (b_j1 = 0; b_j1 < i; b_j1++) {
            double xtmp;
            xtmp = x_data[b_j1];
            nd2 = nx - b_j1;
            x_data[b_j1] = x_data[nd2];
            x_data[nd2] = xtmp;
          }
          nd2 = varargin_2->size[1] >> 1;
          for (b_j1 = 0; b_j1 < nd2; b_j1++) {
            float xtmp_im;
            float xtmp_re;
            nx = (varargin_2->size[1] - b_j1) - 1;
            xtmp_re = y_data[b_j1].re;
            xtmp_im = y_data[b_j1].im;
            y_data[b_j1] = y_data[nx];
            y_data[nx].re = xtmp_re;
            y_data[nx].im = xtmp_im;
          }
        }
        interp1Linear(y, varargin_3, Vq, x);
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }
  emxFree_real_T(&x);
  emxFree_creal32_T(&y);
}

/*
 * File trailer for interp1.c
 *
 * [EOF]
 */
