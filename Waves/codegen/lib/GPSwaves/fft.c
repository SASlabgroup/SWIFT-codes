/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: fft.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "fft.h"
#include "GPSwaves_emxutil.h"
#include "fft1.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *x
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void fft(const emxArray_real_T *x, emxArray_creal_T *y)
{
  int n1;
  boolean_T useRadix2;
  int sz[2];
  int pmax;
  int pmin;
  int nn1m1;
  emxArray_real_T *costab1q;
  boolean_T exitg1;
  double e;
  int nRowsD4;
  int istart;
  int pow2p;
  int k;
  emxArray_real_T *costab;
  emxArray_real_T *sintab;
  emxArray_real_T *sintabinv;
  unsigned int sx[2];
  emxArray_creal_T *rwork;
  int nRowsD2;
  int i;
  double temp_re;
  double temp_im;
  double twid_im;
  int ihi;
  n1 = x->size[0];
  if (x->size[1] == 0) {
    sz[0] = x->size[0];
    pmin = y->size[0] * y->size[1];
    y->size[0] = sz[0];
    y->size[1] = 0;
    emxEnsureCapacity_creal_T(y, pmin);
  } else {
    useRadix2 = ((x->size[0] & (x->size[0] - 1)) == 0);
    pmax = 1;
    if (useRadix2) {
      nn1m1 = x->size[0];
    } else {
      nn1m1 = (x->size[0] + x->size[0]) - 1;
      pmax = 31;
      pmin = 0;
      exitg1 = false;
      while ((!exitg1) && (pmax - pmin > 1)) {
        istart = (pmin + pmax) >> 1;
        pow2p = 1 << istart;
        if (pow2p == nn1m1) {
          pmax = istart;
          exitg1 = true;
        } else if (pow2p > nn1m1) {
          pmax = istart;
        } else {
          pmin = istart;
        }
      }

      pmax = 1 << pmax;
      nn1m1 = pmax;
    }

    emxInit_real_T(&costab1q, 2);
    e = 6.2831853071795862 / (double)nn1m1;
    pmin = (nn1m1 + (nn1m1 < 0)) >> 1;
    nRowsD4 = (pmin + (pmin < 0)) >> 1;
    pmin = costab1q->size[0] * costab1q->size[1];
    costab1q->size[0] = 1;
    costab1q->size[1] = nRowsD4 + 1;
    emxEnsureCapacity_real_T1(costab1q, pmin);
    costab1q->data[0] = 1.0;
    nn1m1 = (nRowsD4 + (nRowsD4 < 0)) >> 1;
    for (k = 1; k <= nn1m1; k++) {
      costab1q->data[k] = cos(e * (double)k);
    }

    for (k = nn1m1 + 1; k < nRowsD4; k++) {
      costab1q->data[k] = sin(e * (double)(nRowsD4 - k));
    }

    costab1q->data[nRowsD4] = 0.0;
    emxInit_real_T(&costab, 2);
    emxInit_real_T(&sintab, 2);
    emxInit_real_T(&sintabinv, 2);
    if (!useRadix2) {
      pow2p = costab1q->size[1] - 1;
      nn1m1 = (costab1q->size[1] - 1) << 1;
      pmin = costab->size[0] * costab->size[1];
      costab->size[0] = 1;
      costab->size[1] = nn1m1 + 1;
      emxEnsureCapacity_real_T1(costab, pmin);
      pmin = sintab->size[0] * sintab->size[1];
      sintab->size[0] = 1;
      sintab->size[1] = nn1m1 + 1;
      emxEnsureCapacity_real_T1(sintab, pmin);
      costab->data[0] = 1.0;
      sintab->data[0] = 0.0;
      pmin = sintabinv->size[0] * sintabinv->size[1];
      sintabinv->size[0] = 1;
      sintabinv->size[1] = nn1m1 + 1;
      emxEnsureCapacity_real_T1(sintabinv, pmin);
      for (k = 1; k <= pow2p; k++) {
        sintabinv->data[k] = costab1q->data[pow2p - k];
      }

      for (k = costab1q->size[1]; k <= nn1m1; k++) {
        sintabinv->data[k] = costab1q->data[k - pow2p];
      }

      for (k = 1; k <= pow2p; k++) {
        costab->data[k] = costab1q->data[k];
        sintab->data[k] = -costab1q->data[pow2p - k];
      }

      for (k = costab1q->size[1]; k <= nn1m1; k++) {
        costab->data[k] = -costab1q->data[nn1m1 - k];
        sintab->data[k] = -costab1q->data[k - pow2p];
      }
    } else {
      pow2p = costab1q->size[1] - 1;
      nn1m1 = (costab1q->size[1] - 1) << 1;
      pmin = costab->size[0] * costab->size[1];
      costab->size[0] = 1;
      costab->size[1] = nn1m1 + 1;
      emxEnsureCapacity_real_T1(costab, pmin);
      pmin = sintab->size[0] * sintab->size[1];
      sintab->size[0] = 1;
      sintab->size[1] = nn1m1 + 1;
      emxEnsureCapacity_real_T1(sintab, pmin);
      costab->data[0] = 1.0;
      sintab->data[0] = 0.0;
      for (k = 1; k <= pow2p; k++) {
        costab->data[k] = costab1q->data[k];
        sintab->data[k] = -costab1q->data[pow2p - k];
      }

      for (k = costab1q->size[1]; k <= nn1m1; k++) {
        costab->data[k] = -costab1q->data[nn1m1 - k];
        sintab->data[k] = -costab1q->data[k - pow2p];
      }

      pmin = sintabinv->size[0] * sintabinv->size[1];
      sintabinv->size[0] = 1;
      sintabinv->size[1] = 0;
      emxEnsureCapacity_real_T1(sintabinv, pmin);
    }

    emxFree_real_T(&costab1q);
    if (useRadix2) {
      for (pmin = 0; pmin < 2; pmin++) {
        sx[pmin] = (unsigned int)x->size[pmin];
      }

      for (pmin = 0; pmin < 2; pmin++) {
        sz[pmin] = x->size[pmin];
      }

      sz[0] = x->size[0];
      pmin = y->size[0] * y->size[1];
      y->size[0] = sz[0];
      y->size[1] = sz[1];
      emxEnsureCapacity_creal_T(y, pmin);
      k = 0;
      emxInit_creal_T1(&rwork, 1);
      while (k + 1 <= (int)sx[1]) {
        istart = x->size[0];
        if (!(istart < n1)) {
          istart = n1;
        }

        nRowsD2 = (n1 + (n1 < 0)) >> 1;
        nRowsD4 = (nRowsD2 + (nRowsD2 < 0)) >> 1;
        pmin = rwork->size[0];
        rwork->size[0] = n1;
        emxEnsureCapacity_creal_T1(rwork, pmin);
        if (n1 > x->size[0]) {
          nn1m1 = rwork->size[0];
          pmin = rwork->size[0];
          rwork->size[0] = nn1m1;
          emxEnsureCapacity_creal_T1(rwork, pmin);
          for (pmin = 0; pmin < nn1m1; pmin++) {
            rwork->data[pmin].re = 0.0;
            rwork->data[pmin].im = 0.0;
          }
        }

        pmax = k * x->size[0];
        pmin = 0;
        nn1m1 = 0;
        for (i = 1; i < istart; i++) {
          rwork->data[nn1m1].re = x->data[pmax];
          rwork->data[nn1m1].im = 0.0;
          pow2p = n1;
          useRadix2 = true;
          while (useRadix2) {
            pow2p >>= 1;
            pmin ^= pow2p;
            useRadix2 = ((pmin & pow2p) == 0);
          }

          nn1m1 = pmin;
          pmax++;
        }

        rwork->data[nn1m1].re = x->data[pmax];
        rwork->data[nn1m1].im = 0.0;
        for (i = 0; i <= n1 - 2; i += 2) {
          temp_re = rwork->data[i + 1].re;
          temp_im = rwork->data[i + 1].im;
          rwork->data[i + 1].re = rwork->data[i].re - rwork->data[i + 1].re;
          rwork->data[i + 1].im = rwork->data[i].im - rwork->data[i + 1].im;
          rwork->data[i].re += temp_re;
          rwork->data[i].im += temp_im;
        }

        nn1m1 = 2;
        pmax = 4;
        pmin = 1 + ((nRowsD4 - 1) << 2);
        while (nRowsD4 > 0) {
          for (i = 0; i < pmin; i += pmax) {
            temp_re = rwork->data[i + nn1m1].re;
            temp_im = rwork->data[i + nn1m1].im;
            rwork->data[i + nn1m1].re = rwork->data[i].re - temp_re;
            rwork->data[i + nn1m1].im = rwork->data[i].im - temp_im;
            rwork->data[i].re += temp_re;
            rwork->data[i].im += temp_im;
          }

          istart = 1;
          for (pow2p = nRowsD4; pow2p < nRowsD2; pow2p += nRowsD4) {
            e = costab->data[pow2p];
            twid_im = sintab->data[pow2p];
            i = istart;
            ihi = istart + pmin;
            while (i < ihi) {
              temp_re = e * rwork->data[i + nn1m1].re - twid_im * rwork->data[i
                + nn1m1].im;
              temp_im = e * rwork->data[i + nn1m1].im + twid_im * rwork->data[i
                + nn1m1].re;
              rwork->data[i + nn1m1].re = rwork->data[i].re - temp_re;
              rwork->data[i + nn1m1].im = rwork->data[i].im - temp_im;
              rwork->data[i].re += temp_re;
              rwork->data[i].im += temp_im;
              i += pmax;
            }

            istart++;
          }

          nRowsD4 >>= 1;
          nn1m1 = pmax;
          pmax += pmax;
          pmin -= nn1m1;
        }

        for (nn1m1 = 0; nn1m1 + 1 <= n1; nn1m1++) {
          y->data[nn1m1 + y->size[0] * k] = rwork->data[nn1m1];
        }

        k++;
      }

      emxFree_creal_T(&rwork);
    } else {
      dobluesteinfft(x, pmax, x->size[0], costab, sintab, sintabinv, y);
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
