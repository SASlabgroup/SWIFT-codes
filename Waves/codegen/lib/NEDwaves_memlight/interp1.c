/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: interp1.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 02-Sep-2023 15:57:28
 */

/* Include Files */
#include "interp1.h"
#include "NEDwaves_memlight_emxutil.h"
#include "NEDwaves_memlight_types.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
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
  const double *varargin_3_data;
  double *x_data;
  int k;
  int low_i;
  int low_ip1;
  int nd2;
  int nx;
  bool b;
  varargin_3_data = varargin_3->data;
  varargin_2_data = varargin_2->data;
  varargin_1_data = varargin_1->data;
  emxInit_creal32_T(&y, 2);
  low_i = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = varargin_2->size[1];
  emxEnsureCapacity_creal32_T(y, low_i);
  y_data = y->data;
  nd2 = varargin_2->size[1];
  for (low_i = 0; low_i < nd2; low_i++) {
    y_data[low_i] = varargin_2_data[low_i];
  }
  emxInit_real_T(&x, 2);
  low_i = x->size[0] * x->size[1];
  x->size[0] = 1;
  x->size[1] = varargin_1->size[1];
  emxEnsureCapacity_real_T(x, low_i);
  x_data = x->data;
  nd2 = varargin_1->size[1];
  for (low_i = 0; low_i < nd2; low_i++) {
    x_data[low_i] = varargin_1_data[low_i];
  }
  nx = varargin_1->size[1] - 1;
  low_i = Vq->size[0] * Vq->size[1];
  Vq->size[0] = 1;
  Vq->size[1] = varargin_3->size[1];
  emxEnsureCapacity_creal32_T(Vq, low_i);
  Vq_data = Vq->data;
  nd2 = varargin_3->size[1];
  for (low_i = 0; low_i < nd2; low_i++) {
    Vq_data[low_i].re = rtNaNF;
    Vq_data[low_i].im = rtNaNF;
  }
  b = (varargin_3->size[1] == 0);
  if (!b) {
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
          low_i = (nx + 1) >> 1;
          for (low_ip1 = 0; low_ip1 < low_i; low_ip1++) {
            xtmp = x_data[low_ip1];
            nd2 = nx - low_ip1;
            x_data[low_ip1] = x_data[nd2];
            x_data[nd2] = xtmp;
          }
          nd2 = varargin_2->size[1] >> 1;
          for (low_ip1 = 0; low_ip1 < nd2; low_ip1++) {
            nx = (varargin_2->size[1] - low_ip1) - 1;
            xtmp_re = y_data[low_ip1].re;
            xtmp_im = y_data[low_ip1].im;
            y_data[low_ip1] = y_data[nx];
            y_data[nx].re = xtmp_re;
            y_data[nx].im = xtmp_im;
          }
        }
        nd2 = varargin_3->size[1];
        for (k = 0; k < nd2; k++) {
          xtmp = varargin_3_data[k];
          if (rtIsNaN(xtmp)) {
            Vq_data[k].re = rtNaNF;
            Vq_data[k].im = rtNaNF;
          } else if ((!(xtmp > x_data[x->size[1] - 1])) &&
                     (!(xtmp < x_data[0]))) {
            nx = x->size[1];
            low_i = 1;
            low_ip1 = 2;
            while (nx > low_ip1) {
              int mid_i;
              mid_i = (low_i >> 1) + (nx >> 1);
              if (((low_i & 1) == 1) && ((nx & 1) == 1)) {
                mid_i++;
              }
              if (varargin_3_data[k] >= x_data[mid_i - 1]) {
                low_i = mid_i;
                low_ip1 = mid_i + 1;
              } else {
                nx = mid_i;
              }
            }
            xtmp = x_data[low_i - 1];
            xtmp = (varargin_3_data[k] - xtmp) / (x_data[low_i] - xtmp);
            if (xtmp == 0.0) {
              Vq_data[k] = y_data[low_i - 1];
            } else if (xtmp == 1.0) {
              Vq_data[k] = y_data[low_i];
            } else {
              creal32_T y_tmp_tmp;
              float y_tmp;
              y_tmp_tmp = y_data[low_i - 1];
              xtmp_re = y_data[low_i].re;
              xtmp_im = y_data[low_i - 1].im;
              y_tmp = y_data[low_i].im;
              if ((y_tmp_tmp.re == xtmp_re) && (xtmp_im == y_tmp)) {
                Vq_data[k] = y_tmp_tmp;
              } else {
                Vq_data[k].re =
                    (float)(1.0 - xtmp) * y_tmp_tmp.re + (float)xtmp * xtmp_re;
                Vq_data[k].im =
                    (float)(1.0 - xtmp) * xtmp_im + (float)xtmp * y_tmp;
              }
            }
          }
        }
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
