/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: fft.c
 *
 * MATLAB Coder version            : 5.4
 * C/C++ source code generated on  : 07-Dec-2022 08:45:24
 */

/* Include Files */
#include "fft.h"
#include "FFTImplementationCallback.h"
#include "NEDwaves_emxutil.h"
#include "NEDwaves_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void fft(const emxArray_real_T *x, emxArray_creal_T *y)
{
  emxArray_creal_T *r;
  emxArray_real_T *costab;
  emxArray_real_T *costab1q;
  emxArray_real_T *sintab;
  emxArray_real_T *sintabinv;
  creal_T *r1;
  creal_T *y_data;
  const double *x_data;
  double *costab1q_data;
  double *costab_data;
  double *sintab_data;
  double *sintabinv_data;
  int chan;
  int i;
  int j;
  int k;
  int nfft;
  int pow2p;
  x_data = x->data;
  nfft = x->size[0];
  if ((x->size[0] == 0) || (x->size[1] == 0)) {
    int pmax;
    pow2p = y->size[0] * y->size[1];
    y->size[0] = x->size[0];
    y->size[1] = x->size[1];
    emxEnsureCapacity_creal_T(y, pow2p);
    y_data = y->data;
    pmax = x->size[0] * x->size[1];
    for (pow2p = 0; pow2p < pmax; pow2p++) {
      y_data[pow2p].re = 0.0;
      y_data[pow2p].im = 0.0;
    }
  } else {
    double temp_im;
    int ihi;
    int pmax;
    int pmin;
    bool useRadix2;
    useRadix2 = ((x->size[0] & (x->size[0] - 1)) == 0);
    pmin = 1;
    if (useRadix2) {
      pmax = x->size[0];
    } else {
      ihi = (x->size[0] + x->size[0]) - 1;
      pmax = 31;
      if (ihi <= 1) {
        pmax = 0;
      } else {
        bool exitg1;
        pmin = 0;
        exitg1 = false;
        while ((!exitg1) && (pmax - pmin > 1)) {
          k = (pmin + pmax) >> 1;
          pow2p = 1 << k;
          if (pow2p == ihi) {
            pmax = k;
            exitg1 = true;
          } else if (pow2p > ihi) {
            pmax = k;
          } else {
            pmin = k;
          }
        }
      }
      pmin = 1 << pmax;
      pmax = pmin;
    }
    emxInit_real_T(&costab1q, 2);
    temp_im = 6.2831853071795862 / (double)pmax;
    ihi = pmax / 2 / 2;
    pow2p = costab1q->size[0] * costab1q->size[1];
    costab1q->size[0] = 1;
    costab1q->size[1] = ihi + 1;
    emxEnsureCapacity_real_T(costab1q, pow2p);
    costab1q_data = costab1q->data;
    costab1q_data[0] = 1.0;
    pmax = ihi / 2 - 1;
    for (k = 0; k <= pmax; k++) {
      costab1q_data[k + 1] = cos(temp_im * ((double)k + 1.0));
    }
    pow2p = pmax + 2;
    pmax = ihi - 1;
    for (k = pow2p; k <= pmax; k++) {
      costab1q_data[k] = sin(temp_im * (double)(ihi - k));
    }
    costab1q_data[ihi] = 0.0;
    emxInit_real_T(&costab, 2);
    emxInit_real_T(&sintab, 2);
    emxInit_real_T(&sintabinv, 2);
    if (!useRadix2) {
      ihi = costab1q->size[1] - 1;
      pmax = (costab1q->size[1] - 1) << 1;
      pow2p = costab->size[0] * costab->size[1];
      costab->size[0] = 1;
      costab->size[1] = pmax + 1;
      emxEnsureCapacity_real_T(costab, pow2p);
      costab_data = costab->data;
      pow2p = sintab->size[0] * sintab->size[1];
      sintab->size[0] = 1;
      sintab->size[1] = pmax + 1;
      emxEnsureCapacity_real_T(sintab, pow2p);
      sintab_data = sintab->data;
      costab_data[0] = 1.0;
      sintab_data[0] = 0.0;
      pow2p = sintabinv->size[0] * sintabinv->size[1];
      sintabinv->size[0] = 1;
      sintabinv->size[1] = pmax + 1;
      emxEnsureCapacity_real_T(sintabinv, pow2p);
      sintabinv_data = sintabinv->data;
      for (k = 0; k < ihi; k++) {
        sintabinv_data[k + 1] = costab1q_data[(ihi - k) - 1];
      }
      pow2p = costab1q->size[1];
      for (k = pow2p; k <= pmax; k++) {
        sintabinv_data[k] = costab1q_data[k - ihi];
      }
      for (k = 0; k < ihi; k++) {
        costab_data[k + 1] = costab1q_data[k + 1];
        sintab_data[k + 1] = -costab1q_data[(ihi - k) - 1];
      }
      pow2p = costab1q->size[1];
      for (k = pow2p; k <= pmax; k++) {
        costab_data[k] = -costab1q_data[pmax - k];
        sintab_data[k] = -costab1q_data[k - ihi];
      }
    } else {
      ihi = costab1q->size[1] - 1;
      pmax = (costab1q->size[1] - 1) << 1;
      pow2p = costab->size[0] * costab->size[1];
      costab->size[0] = 1;
      costab->size[1] = pmax + 1;
      emxEnsureCapacity_real_T(costab, pow2p);
      costab_data = costab->data;
      pow2p = sintab->size[0] * sintab->size[1];
      sintab->size[0] = 1;
      sintab->size[1] = pmax + 1;
      emxEnsureCapacity_real_T(sintab, pow2p);
      sintab_data = sintab->data;
      costab_data[0] = 1.0;
      sintab_data[0] = 0.0;
      for (k = 0; k < ihi; k++) {
        costab_data[k + 1] = costab1q_data[k + 1];
        sintab_data[k + 1] = -costab1q_data[(ihi - k) - 1];
      }
      pow2p = costab1q->size[1];
      for (k = pow2p; k <= pmax; k++) {
        costab_data[k] = -costab1q_data[pmax - k];
        sintab_data[k] = -costab1q_data[k - ihi];
      }
      sintabinv->size[0] = 1;
      sintabinv->size[1] = 0;
    }
    emxFree_real_T(&costab1q);
    if (useRadix2) {
      int nChan;
      int sz_idx_0;
      nChan = x->size[1];
      pow2p = y->size[0] * y->size[1];
      y->size[0] = x->size[0];
      y->size[1] = x->size[1];
      emxEnsureCapacity_creal_T(y, pow2p);
      y_data = y->data;
      sz_idx_0 = x->size[0];
      useRadix2 = (x->size[0] != 1);
      emxInit_creal_T(&r, 1);
      for (chan = 0; chan < nChan; chan++) {
        j = chan * x->size[0];
        pow2p = r->size[0];
        r->size[0] = nfft;
        emxEnsureCapacity_creal_T(r, pow2p);
        r1 = r->data;
        if (nfft > x->size[0]) {
          pow2p = r->size[0];
          r->size[0] = sz_idx_0;
          emxEnsureCapacity_creal_T(r, pow2p);
          r1 = r->data;
          for (pow2p = 0; pow2p < sz_idx_0; pow2p++) {
            r1[pow2p].re = 0.0;
            r1[pow2p].im = 0.0;
          }
        }
        if (useRadix2) {
          c_FFTImplementationCallback_doH(x, j, r, nfft, costab, sintab);
          r1 = r->data;
        } else {
          double temp_re;
          double temp_re_tmp;
          double twid_re;
          int ju;
          int nRowsD2;
          pmin = x->size[0];
          if (pmin > nfft) {
            pmin = nfft;
          }
          pow2p = nfft - 2;
          nRowsD2 = nfft / 2;
          k = nRowsD2 / 2;
          pmax = 0;
          ju = 0;
          for (i = 0; i <= pmin - 2; i++) {
            bool tst;
            r1[pmax].re = x_data[j + i];
            r1[pmax].im = 0.0;
            ihi = nfft;
            tst = true;
            while (tst) {
              ihi >>= 1;
              ju ^= ihi;
              tst = ((ju & ihi) == 0);
            }
            pmax = ju;
          }
          r1[pmax].re = x_data[(j + pmin) - 1];
          r1[pmax].im = 0.0;
          if (nfft > 1) {
            for (i = 0; i <= pow2p; i += 2) {
              temp_re_tmp = r1[i + 1].re;
              temp_im = r1[i + 1].im;
              temp_re = r1[i].re;
              twid_re = r1[i].im;
              r1[i + 1].re = temp_re - temp_re_tmp;
              r1[i + 1].im = twid_re - temp_im;
              r1[i].re = temp_re + temp_re_tmp;
              r1[i].im = twid_re + temp_im;
            }
          }
          pmax = 2;
          pmin = 4;
          pow2p = ((k - 1) << 2) + 1;
          while (k > 0) {
            int b_temp_re_tmp;
            for (i = 0; i < pow2p; i += pmin) {
              b_temp_re_tmp = i + pmax;
              temp_re = r1[b_temp_re_tmp].re;
              temp_im = r1[b_temp_re_tmp].im;
              r1[b_temp_re_tmp].re = r1[i].re - temp_re;
              r1[b_temp_re_tmp].im = r1[i].im - temp_im;
              r1[i].re += temp_re;
              r1[i].im += temp_im;
            }
            ju = 1;
            for (j = k; j < nRowsD2; j += k) {
              double twid_im;
              twid_re = costab_data[j];
              twid_im = sintab_data[j];
              i = ju;
              ihi = ju + pow2p;
              while (i < ihi) {
                b_temp_re_tmp = i + pmax;
                temp_re_tmp = r1[b_temp_re_tmp].im;
                temp_im = r1[b_temp_re_tmp].re;
                temp_re = twid_re * temp_im - twid_im * temp_re_tmp;
                temp_im = twid_re * temp_re_tmp + twid_im * temp_im;
                r1[b_temp_re_tmp].re = r1[i].re - temp_re;
                r1[b_temp_re_tmp].im = r1[i].im - temp_im;
                r1[i].re += temp_re;
                r1[i].im += temp_im;
                i += pmin;
              }
              ju++;
            }
            k /= 2;
            pmax = pmin;
            pmin += pmin;
            pow2p -= pmax;
          }
        }
        pmax = r->size[0];
        for (pow2p = 0; pow2p < pmax; pow2p++) {
          y_data[pow2p + y->size[0] * chan] = r1[pow2p];
        }
      }
      emxFree_creal_T(&r);
    } else {
      c_FFTImplementationCallback_dob(x, pmin, x->size[0], costab, sintab,
                                      sintabinv, y);
    }
    emxFree_real_T(&sintabinv);
    emxFree_real_T(&sintab);
    emxFree_real_T(&costab);
  }
}

/*
 * File trailer for fft.c
 *
 * [EOF]
 */
