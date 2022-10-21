/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: fft1.c
 *
 * MATLAB Coder version            : 3.4
 * C/C++ source code generated on  : 09-Sep-2019 14:24:10
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "GPSwaves.h"
#include "fft1.h"
#include "GPSwaves_emxutil.h"

/* Function Declarations */
static void bluestein(const emxArray_real_T *x, int xoffInit, int nfft, int
                      nRows, const emxArray_real_T *costab, const
                      emxArray_real_T *sintab, const emxArray_real_T *costabinv,
                      const emxArray_real_T *sintabinv, const emxArray_creal_T
                      *wwc, emxArray_creal_T *y);
static void r2br_r2dit_trig_impl(const emxArray_creal_T *x, int unsigned_nRows,
  const emxArray_real_T *costab, const emxArray_real_T *sintab, emxArray_creal_T
  *y);

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *x
 *                int xoffInit
 *                int nfft
 *                int nRows
 *                const emxArray_real_T *costab
 *                const emxArray_real_T *sintab
 *                const emxArray_real_T *costabinv
 *                const emxArray_real_T *sintabinv
 *                const emxArray_creal_T *wwc
 *                emxArray_creal_T *y
 * Return Type  : void
 */
static void bluestein(const emxArray_real_T *x, int xoffInit, int nfft, int
                      nRows, const emxArray_real_T *costab, const
                      emxArray_real_T *sintab, const emxArray_real_T *costabinv,
                      const emxArray_real_T *sintabinv, const emxArray_creal_T
                      *wwc, emxArray_creal_T *y)
{
  int minNrowsNx;
  int ix;
  int xidx;
  double r;
  double twid_im;
  int istart;
  emxArray_creal_T *fy;
  int nRowsD2;
  int nRowsD4;
  int i;
  boolean_T tst;
  double temp_re;
  double temp_im;
  emxArray_creal_T *fv;
  int j;
  double fv_re;
  double fv_im;
  int ihi;
  double wwc_im;
  double b_fv_re;
  minNrowsNx = x->size[0];
  if (nRows < minNrowsNx) {
    minNrowsNx = nRows;
  }

  ix = y->size[0];
  y->size[0] = nRows;
  emxEnsureCapacity_creal_T1(y, ix);
  if (nRows > x->size[0]) {
    xidx = y->size[0];
    ix = y->size[0];
    y->size[0] = xidx;
    emxEnsureCapacity_creal_T1(y, ix);
    for (ix = 0; ix < xidx; ix++) {
      y->data[ix].re = 0.0;
      y->data[ix].im = 0.0;
    }
  }

  xidx = xoffInit;
  for (ix = 0; ix + 1 <= minNrowsNx; ix++) {
    r = wwc->data[(nRows + ix) - 1].re;
    twid_im = wwc->data[(nRows + ix) - 1].im;
    y->data[ix].re = r * x->data[xidx];
    y->data[ix].im = twid_im * -x->data[xidx];
    xidx++;
  }

  while (minNrowsNx + 1 <= nRows) {
    y->data[minNrowsNx].re = 0.0;
    y->data[minNrowsNx].im = 0.0;
    minNrowsNx++;
  }

  istart = y->size[0];
  if (!(istart < nfft)) {
    istart = nfft;
  }

  emxInit_creal_T1(&fy, 1);
  nRowsD2 = (nfft + (nfft < 0)) >> 1;
  nRowsD4 = (nRowsD2 + (nRowsD2 < 0)) >> 1;
  ix = fy->size[0];
  fy->size[0] = nfft;
  emxEnsureCapacity_creal_T1(fy, ix);
  if (nfft > y->size[0]) {
    xidx = fy->size[0];
    ix = fy->size[0];
    fy->size[0] = xidx;
    emxEnsureCapacity_creal_T1(fy, ix);
    for (ix = 0; ix < xidx; ix++) {
      fy->data[ix].re = 0.0;
      fy->data[ix].im = 0.0;
    }
  }

  ix = 0;
  minNrowsNx = 0;
  xidx = 0;
  for (i = 1; i < istart; i++) {
    fy->data[xidx] = y->data[ix];
    xidx = nfft;
    tst = true;
    while (tst) {
      xidx >>= 1;
      minNrowsNx ^= xidx;
      tst = ((minNrowsNx & xidx) == 0);
    }

    xidx = minNrowsNx;
    ix++;
  }

  fy->data[xidx] = y->data[ix];
  if (nfft > 1) {
    for (i = 0; i <= nfft - 2; i += 2) {
      temp_re = fy->data[i + 1].re;
      temp_im = fy->data[i + 1].im;
      fy->data[i + 1].re = fy->data[i].re - fy->data[i + 1].re;
      fy->data[i + 1].im = fy->data[i].im - fy->data[i + 1].im;
      fy->data[i].re += temp_re;
      fy->data[i].im += temp_im;
    }
  }

  xidx = 2;
  minNrowsNx = 4;
  ix = 1 + ((nRowsD4 - 1) << 2);
  while (nRowsD4 > 0) {
    for (i = 0; i < ix; i += minNrowsNx) {
      temp_re = fy->data[i + xidx].re;
      temp_im = fy->data[i + xidx].im;
      fy->data[i + xidx].re = fy->data[i].re - temp_re;
      fy->data[i + xidx].im = fy->data[i].im - temp_im;
      fy->data[i].re += temp_re;
      fy->data[i].im += temp_im;
    }

    istart = 1;
    for (j = nRowsD4; j < nRowsD2; j += nRowsD4) {
      r = costab->data[j];
      twid_im = sintab->data[j];
      i = istart;
      ihi = istart + ix;
      while (i < ihi) {
        temp_re = r * fy->data[i + xidx].re - twid_im * fy->data[i + xidx].im;
        temp_im = r * fy->data[i + xidx].im + twid_im * fy->data[i + xidx].re;
        fy->data[i + xidx].re = fy->data[i].re - temp_re;
        fy->data[i + xidx].im = fy->data[i].im - temp_im;
        fy->data[i].re += temp_re;
        fy->data[i].im += temp_im;
        i += minNrowsNx;
      }

      istart++;
    }

    nRowsD4 >>= 1;
    xidx = minNrowsNx;
    minNrowsNx += minNrowsNx;
    ix -= xidx;
  }

  emxInit_creal_T1(&fv, 1);
  r2br_r2dit_trig_impl(wwc, nfft, costab, sintab, fv);
  ix = fy->size[0];
  emxEnsureCapacity_creal_T1(fy, ix);
  xidx = fy->size[0];
  for (ix = 0; ix < xidx; ix++) {
    r = fy->data[ix].re;
    twid_im = fy->data[ix].im;
    fv_re = fv->data[ix].re;
    fv_im = fv->data[ix].im;
    fy->data[ix].re = r * fv_re - twid_im * fv_im;
    fy->data[ix].im = r * fv_im + twid_im * fv_re;
  }

  r2br_r2dit_trig_impl(fy, nfft, costabinv, sintabinv, fv);
  emxFree_creal_T(&fy);
  if (fv->size[0] > 1) {
    r = 1.0 / (double)fv->size[0];
    ix = fv->size[0];
    emxEnsureCapacity_creal_T1(fv, ix);
    xidx = fv->size[0];
    for (ix = 0; ix < xidx; ix++) {
      fv->data[ix].re *= r;
      fv->data[ix].im *= r;
    }
  }

  xidx = 0;
  for (ix = nRows - 1; ix + 1 <= wwc->size[0]; ix++) {
    r = wwc->data[ix].re;
    fv_re = fv->data[ix].re;
    twid_im = wwc->data[ix].im;
    fv_im = fv->data[ix].im;
    temp_re = wwc->data[ix].re;
    temp_im = fv->data[ix].im;
    wwc_im = wwc->data[ix].im;
    b_fv_re = fv->data[ix].re;
    y->data[xidx].re = r * fv_re + twid_im * fv_im;
    y->data[xidx].im = temp_re * temp_im - wwc_im * b_fv_re;
    xidx++;
  }

  emxFree_creal_T(&fv);
}

/*
 * Arguments    : const emxArray_creal_T *x
 *                int unsigned_nRows
 *                const emxArray_real_T *costab
 *                const emxArray_real_T *sintab
 *                emxArray_creal_T *y
 * Return Type  : void
 */
static void r2br_r2dit_trig_impl(const emxArray_creal_T *x, int unsigned_nRows,
  const emxArray_real_T *costab, const emxArray_real_T *sintab, emxArray_creal_T
  *y)
{
  int j;
  int nRowsD2;
  int nRowsD4;
  int iy;
  int iDelta;
  int ix;
  int ju;
  int i;
  boolean_T tst;
  double temp_re;
  double temp_im;
  double twid_re;
  double twid_im;
  int ihi;
  j = x->size[0];
  if (!(j < unsigned_nRows)) {
    j = unsigned_nRows;
  }

  nRowsD2 = (unsigned_nRows + (unsigned_nRows < 0)) >> 1;
  nRowsD4 = (nRowsD2 + (nRowsD2 < 0)) >> 1;
  iy = y->size[0];
  y->size[0] = unsigned_nRows;
  emxEnsureCapacity_creal_T1(y, iy);
  if (unsigned_nRows > x->size[0]) {
    iDelta = y->size[0];
    iy = y->size[0];
    y->size[0] = iDelta;
    emxEnsureCapacity_creal_T1(y, iy);
    for (iy = 0; iy < iDelta; iy++) {
      y->data[iy].re = 0.0;
      y->data[iy].im = 0.0;
    }
  }

  ix = 0;
  ju = 0;
  iy = 0;
  for (i = 1; i < j; i++) {
    y->data[iy] = x->data[ix];
    iDelta = unsigned_nRows;
    tst = true;
    while (tst) {
      iDelta >>= 1;
      ju ^= iDelta;
      tst = ((ju & iDelta) == 0);
    }

    iy = ju;
    ix++;
  }

  y->data[iy] = x->data[ix];
  if (unsigned_nRows > 1) {
    for (i = 0; i <= unsigned_nRows - 2; i += 2) {
      temp_re = y->data[i + 1].re;
      temp_im = y->data[i + 1].im;
      y->data[i + 1].re = y->data[i].re - y->data[i + 1].re;
      y->data[i + 1].im = y->data[i].im - y->data[i + 1].im;
      y->data[i].re += temp_re;
      y->data[i].im += temp_im;
    }
  }

  iDelta = 2;
  iy = 4;
  ix = 1 + ((nRowsD4 - 1) << 2);
  while (nRowsD4 > 0) {
    for (i = 0; i < ix; i += iy) {
      temp_re = y->data[i + iDelta].re;
      temp_im = y->data[i + iDelta].im;
      y->data[i + iDelta].re = y->data[i].re - temp_re;
      y->data[i + iDelta].im = y->data[i].im - temp_im;
      y->data[i].re += temp_re;
      y->data[i].im += temp_im;
    }

    ju = 1;
    for (j = nRowsD4; j < nRowsD2; j += nRowsD4) {
      twid_re = costab->data[j];
      twid_im = sintab->data[j];
      i = ju;
      ihi = ju + ix;
      while (i < ihi) {
        temp_re = twid_re * y->data[i + iDelta].re - twid_im * y->data[i +
          iDelta].im;
        temp_im = twid_re * y->data[i + iDelta].im + twid_im * y->data[i +
          iDelta].re;
        y->data[i + iDelta].re = y->data[i].re - temp_re;
        y->data[i + iDelta].im = y->data[i].im - temp_im;
        y->data[i].re += temp_re;
        y->data[i].im += temp_im;
        i += iy;
      }

      ju++;
    }

    nRowsD4 >>= 1;
    iDelta = iy;
    iy += iy;
    ix -= iDelta;
  }
}

/*
 * Arguments    : const emxArray_real_T *x
 *                int N2
 *                int n1
 *                const emxArray_real_T *costab
 *                const emxArray_real_T *sintab
 *                const emxArray_real_T *sintabinv
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void dobluesteinfft(const emxArray_real_T *x, int N2, int n1, const
                    emxArray_real_T *costab, const emxArray_real_T *sintab,
                    const emxArray_real_T *sintabinv, emxArray_creal_T *y)
{
  int b_y;
  emxArray_creal_T *wwc;
  unsigned int sx[2];
  int nInt2m1;
  int idx;
  int rt;
  int nInt2;
  int k;
  double nt_im;
  int sz[2];
  double nt_re;
  emxArray_creal_T *rwork;
  for (b_y = 0; b_y < 2; b_y++) {
    sx[b_y] = (unsigned int)x->size[b_y];
  }

  emxInit_creal_T1(&wwc, 1);
  nInt2m1 = (n1 + n1) - 1;
  b_y = wwc->size[0];
  wwc->size[0] = nInt2m1;
  emxEnsureCapacity_creal_T1(wwc, b_y);
  idx = n1;
  rt = 0;
  wwc->data[n1 - 1].re = 1.0;
  wwc->data[n1 - 1].im = 0.0;
  nInt2 = n1 << 1;
  for (k = 1; k < n1; k++) {
    b_y = (k << 1) - 1;
    if (nInt2 - rt <= b_y) {
      rt += b_y - nInt2;
    } else {
      rt += b_y;
    }

    nt_im = -3.1415926535897931 * (double)rt / (double)n1;
    if (nt_im == 0.0) {
      nt_re = 1.0;
      nt_im = 0.0;
    } else {
      nt_re = cos(nt_im);
      nt_im = sin(nt_im);
    }

    wwc->data[idx - 2].re = nt_re;
    wwc->data[idx - 2].im = -nt_im;
    idx--;
  }

  idx = 0;
  for (k = nInt2m1 - 1; k >= n1; k--) {
    wwc->data[k] = wwc->data[idx];
    idx++;
  }

  for (b_y = 0; b_y < 2; b_y++) {
    sz[b_y] = x->size[b_y];
  }

  b_y = y->size[0] * y->size[1];
  y->size[0] = n1;
  y->size[1] = sz[1];
  emxEnsureCapacity_creal_T(y, b_y);
  if (n1 > x->size[0]) {
    b_y = y->size[0] * y->size[1];
    emxEnsureCapacity_creal_T(y, b_y);
    idx = y->size[1];
    for (b_y = 0; b_y < idx; b_y++) {
      rt = y->size[0];
      for (nInt2 = 0; nInt2 < rt; nInt2++) {
        y->data[nInt2 + y->size[0] * b_y].re = 0.0;
        y->data[nInt2 + y->size[0] * b_y].im = 0.0;
      }
    }
  }

  k = 0;
  emxInit_creal_T1(&rwork, 1);
  while (k + 1 <= (int)sx[1]) {
    bluestein(x, k * x->size[0], N2, n1, costab, sintab, costab, sintabinv, wwc,
              rwork);
    for (idx = 0; idx + 1 <= n1; idx++) {
      y->data[idx + y->size[0] * k] = rwork->data[idx];
    }

    k++;
  }

  emxFree_creal_T(&rwork);
  emxFree_creal_T(&wwc);
}

/*
 * File trailer for fft1.c
 *
 * [EOF]
 */
