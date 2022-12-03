//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// FFTImplementationCallback.cpp
//
// Code generation for function 'FFTImplementationCallback'
//

// Include files
#include "FFTImplementationCallback.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "omp.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace fft {
void FFTImplementationCallback::doHalfLengthBluestein(
    const ::coder::array<double, 2U> &x, int xoffInit,
    ::coder::array<creal_T, 1U> &y, int nrowsx, int nRows, int nfft,
    const ::coder::array<creal_T, 1U> &wwc,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab,
    const ::coder::array<double, 2U> &costabinv,
    const ::coder::array<double, 2U> &sintabinv)
{
  array<creal_T, 1U> fv;
  array<creal_T, 1U> fy;
  array<creal_T, 1U> reconVar1;
  array<creal_T, 1U> reconVar2;
  array<creal_T, 1U> ytmp;
  array<double, 2U> b_costab;
  array<double, 2U> b_sintab;
  array<double, 2U> costab1q;
  array<double, 2U> hcostabinv;
  array<double, 2U> hsintab;
  array<double, 2U> hsintabinv;
  array<int, 2U> wrapIndex;
  double re_tmp;
  double temp_im;
  double temp_re;
  double temp_re_tmp;
  double twid_im;
  double twid_re;
  double z_tmp;
  int hnRows;
  int i;
  int iDelta2;
  int ihi;
  int istart;
  int j;
  int ju;
  int k;
  int nRowsD2;
  int nd2;
  bool tst;
  hnRows = (nRows + (nRows < 0)) >> 1;
  ytmp.set_size(hnRows);
  if (hnRows > nrowsx) {
    ytmp.set_size(hnRows);
    for (iDelta2 = 0; iDelta2 < hnRows; iDelta2++) {
      ytmp[iDelta2].re = 0.0;
      ytmp[iDelta2].im = 0.0;
    }
  }
  if ((x.size(0) & 1) == 0) {
    tst = true;
    ihi = x.size(0);
  } else if (x.size(0) >= nRows) {
    tst = true;
    ihi = nRows;
  } else {
    tst = false;
    ihi = x.size(0) - 1;
  }
  if (ihi > nRows) {
    ihi = nRows;
  }
  nd2 = nRows << 1;
  temp_im = 6.2831853071795862 / static_cast<double>(nd2);
  iDelta2 = (nd2 + (nd2 < 0)) >> 1;
  j = (iDelta2 + (iDelta2 < 0)) >> 1;
  costab1q.set_size(1, j + 1);
  costab1q[0] = 1.0;
  nd2 = ((j + (j < 0)) >> 1) - 1;
  for (k = 0; k <= nd2; k++) {
    costab1q[k + 1] = std::cos(temp_im * (static_cast<double>(k) + 1.0));
  }
  iDelta2 = nd2 + 2;
  nd2 = j - 1;
  for (k = iDelta2; k <= nd2; k++) {
    costab1q[k] = std::sin(temp_im * static_cast<double>(j - k));
  }
  costab1q[j] = 0.0;
  j = costab1q.size(1) - 1;
  nd2 = (costab1q.size(1) - 1) << 1;
  b_costab.set_size(1, nd2 + 1);
  b_sintab.set_size(1, nd2 + 1);
  b_costab[0] = 1.0;
  b_sintab[0] = 0.0;
  for (k = 0; k < j; k++) {
    b_costab[k + 1] = costab1q[k + 1];
    b_sintab[k + 1] = -costab1q[(j - k) - 1];
  }
  iDelta2 = costab1q.size(1);
  for (k = iDelta2; k <= nd2; k++) {
    b_costab[k] = -costab1q[nd2 - k];
    b_sintab[k] = -costab1q[k - j];
  }
  nd2 = costab.size(1) >> 1;
  costab1q.set_size(1, nd2);
  hsintab.set_size(1, nd2);
  hcostabinv.set_size(1, nd2);
  hsintabinv.set_size(1, nd2);
  for (i = 0; i < nd2; i++) {
    iDelta2 = ((i + 1) << 1) - 2;
    costab1q[i] = costab[iDelta2];
    hsintab[i] = sintab[iDelta2];
    hcostabinv[i] = costabinv[iDelta2];
    hsintabinv[i] = sintabinv[iDelta2];
  }
  reconVar1.set_size(hnRows);
  reconVar2.set_size(hnRows);
  wrapIndex.set_size(1, hnRows);
  for (i = 0; i < hnRows; i++) {
    iDelta2 = i << 1;
    temp_im = b_sintab[iDelta2];
    temp_re = b_costab[iDelta2];
    reconVar1[i].re = temp_im + 1.0;
    reconVar1[i].im = -temp_re;
    reconVar2[i].re = 1.0 - temp_im;
    reconVar2[i].im = temp_re;
    if (i + 1 != 1) {
      wrapIndex[i] = (hnRows - i) + 1;
    } else {
      wrapIndex[0] = 1;
    }
  }
  z_tmp = static_cast<double>(ihi) / 2.0;
  iDelta2 = static_cast<int>(z_tmp);
  for (ju = 0; ju < iDelta2; ju++) {
    temp_re = wwc[(hnRows + ju) - 1].re;
    temp_im = wwc[(hnRows + ju) - 1].im;
    nd2 = xoffInit + (ju << 1);
    twid_re = x[nd2];
    twid_im = x[nd2 + 1];
    ytmp[ju].re = temp_re * twid_re + temp_im * twid_im;
    ytmp[ju].im = temp_re * twid_im - temp_im * twid_re;
  }
  if (!tst) {
    temp_re = wwc[(hnRows + static_cast<int>(z_tmp)) - 1].re;
    temp_im = wwc[(hnRows + static_cast<int>(z_tmp)) - 1].im;
    twid_re = x[xoffInit + (static_cast<int>(z_tmp) << 1)];
    ytmp[static_cast<int>(z_tmp)].re = temp_re * twid_re + temp_im * 0.0;
    ytmp[static_cast<int>(z_tmp)].im = temp_re * 0.0 - temp_im * twid_re;
    if (static_cast<int>(z_tmp) + 2 <= hnRows) {
      iDelta2 = static_cast<int>(static_cast<double>(ihi) / 2.0) + 2;
      for (i = iDelta2; i <= hnRows; i++) {
        ytmp[i - 1].re = 0.0;
        ytmp[i - 1].im = 0.0;
      }
    }
  } else if (static_cast<int>(z_tmp) + 1 <= hnRows) {
    iDelta2 = static_cast<int>(static_cast<double>(ihi) / 2.0) + 1;
    for (i = iDelta2; i <= hnRows; i++) {
      ytmp[i - 1].re = 0.0;
      ytmp[i - 1].im = 0.0;
    }
  }
  z_tmp = static_cast<double>(nfft) / 2.0;
  nd2 = static_cast<int>(z_tmp);
  fy.set_size(nd2);
  if (static_cast<int>(z_tmp) > ytmp.size(0)) {
    fy.set_size(nd2);
    for (iDelta2 = 0; iDelta2 < nd2; iDelta2++) {
      fy[iDelta2].re = 0.0;
      fy[iDelta2].im = 0.0;
    }
  }
  ihi = ytmp.size(0);
  istart = static_cast<int>(z_tmp);
  if (ihi <= istart) {
    istart = ihi;
  }
  iDelta2 = static_cast<int>(z_tmp) - 2;
  nRowsD2 = (static_cast<int>(z_tmp) + (static_cast<int>(z_tmp) < 0)) >> 1;
  k = (nRowsD2 + (nRowsD2 < 0)) >> 1;
  nd2 = 0;
  ju = 0;
  for (i = 0; i <= istart - 2; i++) {
    fy[nd2] = ytmp[i];
    j = static_cast<int>(z_tmp);
    tst = true;
    while (tst) {
      j >>= 1;
      ju ^= j;
      tst = ((ju & j) == 0);
    }
    nd2 = ju;
  }
  fy[nd2] = ytmp[istart - 1];
  if (static_cast<int>(z_tmp) > 1) {
    for (i = 0; i <= iDelta2; i += 2) {
      temp_re_tmp = fy[i + 1].re;
      temp_re = fy[i + 1].im;
      re_tmp = fy[i].re;
      twid_re = fy[i].im;
      fy[i + 1].re = re_tmp - temp_re_tmp;
      fy[i + 1].im = twid_re - temp_re;
      fy[i].re = re_tmp + temp_re_tmp;
      fy[i].im = twid_re + temp_re;
    }
  }
  nd2 = 2;
  iDelta2 = 4;
  ju = ((k - 1) << 2) + 1;
  while (k > 0) {
    int b_temp_re_tmp;
    for (i = 0; i < ju; i += iDelta2) {
      b_temp_re_tmp = i + nd2;
      temp_re = fy[b_temp_re_tmp].re;
      temp_im = fy[b_temp_re_tmp].im;
      fy[b_temp_re_tmp].re = fy[i].re - temp_re;
      fy[b_temp_re_tmp].im = fy[i].im - temp_im;
      fy[i].re = fy[i].re + temp_re;
      fy[i].im = fy[i].im + temp_im;
    }
    istart = 1;
    for (j = k; j < nRowsD2; j += k) {
      twid_re = costab1q[j];
      twid_im = hsintab[j];
      i = istart;
      ihi = istart + ju;
      while (i < ihi) {
        b_temp_re_tmp = i + nd2;
        temp_re_tmp = fy[b_temp_re_tmp].im;
        temp_im = fy[b_temp_re_tmp].re;
        temp_re = twid_re * temp_im - twid_im * temp_re_tmp;
        temp_im = twid_re * temp_re_tmp + twid_im * temp_im;
        fy[b_temp_re_tmp].re = fy[i].re - temp_re;
        fy[b_temp_re_tmp].im = fy[i].im - temp_im;
        fy[i].re = fy[i].re + temp_re;
        fy[i].im = fy[i].im + temp_im;
        i += iDelta2;
      }
      istart++;
    }
    k >>= 1;
    nd2 = iDelta2;
    iDelta2 += iDelta2;
    ju -= nd2;
  }
  FFTImplementationCallback::r2br_r2dit_trig_impl(wwc, static_cast<int>(z_tmp),
                                                  costab1q, hsintab, fv);
  nd2 = fy.size(0);
  for (iDelta2 = 0; iDelta2 < nd2; iDelta2++) {
    re_tmp = fy[iDelta2].re;
    twid_im = fv[iDelta2].im;
    temp_im = fy[iDelta2].im;
    temp_re = fv[iDelta2].re;
    fy[iDelta2].re = re_tmp * temp_re - temp_im * twid_im;
    fy[iDelta2].im = re_tmp * twid_im + temp_im * temp_re;
  }
  FFTImplementationCallback::r2br_r2dit_trig_impl(fy, static_cast<int>(z_tmp),
                                                  hcostabinv, hsintabinv, fv);
  if (fv.size(0) > 1) {
    temp_im = 1.0 / static_cast<double>(fv.size(0));
    nd2 = fv.size(0);
    for (iDelta2 = 0; iDelta2 < nd2; iDelta2++) {
      fv[iDelta2].re = temp_im * fv[iDelta2].re;
      fv[iDelta2].im = temp_im * fv[iDelta2].im;
    }
  }
  iDelta2 = wwc.size(0);
  for (k = hnRows; k <= iDelta2; k++) {
    temp_im = wwc[k - 1].re;
    temp_re = fv[k - 1].im;
    twid_re = wwc[k - 1].im;
    twid_im = fv[k - 1].re;
    ytmp[k - hnRows].re = temp_im * twid_im + twid_re * temp_re;
    ytmp[k - hnRows].im = temp_im * temp_re - twid_re * twid_im;
  }
  for (i = 0; i < hnRows; i++) {
    double ytmp_re_tmp;
    iDelta2 = wrapIndex[i];
    temp_im = ytmp[i].re;
    temp_re = reconVar1[i].im;
    twid_re = ytmp[i].im;
    twid_im = reconVar1[i].re;
    re_tmp = ytmp[iDelta2 - 1].re;
    temp_re_tmp = -ytmp[iDelta2 - 1].im;
    z_tmp = reconVar2[i].im;
    ytmp_re_tmp = reconVar2[i].re;
    y[i].re = 0.5 * ((temp_im * twid_im - twid_re * temp_re) +
                     (re_tmp * ytmp_re_tmp - temp_re_tmp * z_tmp));
    y[i].im = 0.5 * ((temp_im * temp_re + twid_re * twid_im) +
                     (re_tmp * z_tmp + temp_re_tmp * ytmp_re_tmp));
    y[hnRows + i].re = 0.5 * ((temp_im * ytmp_re_tmp - twid_re * z_tmp) +
                              (re_tmp * twid_im - temp_re_tmp * temp_re));
    y[hnRows + i].im = 0.5 * ((temp_im * z_tmp + twid_re * ytmp_re_tmp) +
                              (re_tmp * temp_re + temp_re_tmp * twid_im));
  }
}

void FFTImplementationCallback::doHalfLengthRadix2(
    const ::coder::array<double, 2U> &x, int xoffInit,
    ::coder::array<creal_T, 1U> &y, int unsigned_nRows,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab)
{
  array<creal_T, 1U> reconVar1;
  array<creal_T, 1U> reconVar2;
  array<double, 2U> hcostab;
  array<double, 2U> hsintab;
  array<int, 2U> wrapIndex;
  array<int, 1U> bitrevIndex;
  double b_y_re_tmp;
  double c_y_re_tmp;
  double d_y_re_tmp;
  double temp2_im;
  double temp2_re;
  double temp_im;
  double temp_im_tmp;
  double temp_re;
  double temp_re_tmp;
  double y_re_tmp;
  double z_tmp;
  int hszCostab;
  int i;
  int istart;
  int iy;
  int j;
  int ju;
  int k;
  int nRows;
  int nRowsD2;
  int nRowsM2;
  bool tst;
  nRows = (unsigned_nRows + (unsigned_nRows < 0)) >> 1;
  j = y.size(0);
  if (j > nRows) {
    j = nRows;
  }
  nRowsM2 = nRows - 2;
  nRowsD2 = (nRows + (nRows < 0)) >> 1;
  k = (nRowsD2 + (nRowsD2 < 0)) >> 1;
  hszCostab = costab.size(1) >> 1;
  hcostab.set_size(1, hszCostab);
  hsintab.set_size(1, hszCostab);
  for (i = 0; i < hszCostab; i++) {
    iy = ((i + 1) << 1) - 2;
    hcostab[i] = costab[iy];
    hsintab[i] = sintab[iy];
  }
  reconVar1.set_size(nRows);
  reconVar2.set_size(nRows);
  wrapIndex.set_size(1, nRows);
  for (i = 0; i < nRows; i++) {
    temp_re = sintab[i];
    temp2_re = costab[i];
    reconVar1[i].re = temp_re + 1.0;
    reconVar1[i].im = -temp2_re;
    reconVar2[i].re = 1.0 - temp_re;
    reconVar2[i].im = temp2_re;
    if (i + 1 != 1) {
      wrapIndex[i] = (nRows - i) + 1;
    } else {
      wrapIndex[0] = 1;
    }
  }
  z_tmp = static_cast<double>(unsigned_nRows) / 2.0;
  ju = 0;
  iy = 1;
  hszCostab = static_cast<int>(z_tmp);
  bitrevIndex.set_size(hszCostab);
  for (istart = 0; istart < hszCostab; istart++) {
    bitrevIndex[istart] = 0;
  }
  for (istart = 0; istart <= j - 2; istart++) {
    bitrevIndex[istart] = iy;
    hszCostab = static_cast<int>(z_tmp);
    tst = true;
    while (tst) {
      hszCostab >>= 1;
      ju ^= hszCostab;
      tst = ((ju & hszCostab) == 0);
    }
    iy = ju + 1;
  }
  bitrevIndex[j - 1] = iy;
  if ((x.size(0) & 1) == 0) {
    tst = true;
    j = x.size(0);
  } else if (x.size(0) >= unsigned_nRows) {
    tst = true;
    j = unsigned_nRows;
  } else {
    tst = false;
    j = x.size(0) - 1;
  }
  if (j > unsigned_nRows) {
    j = unsigned_nRows;
  }
  temp_re = static_cast<double>(j) / 2.0;
  istart = static_cast<int>(temp_re);
  for (i = 0; i < istart; i++) {
    iy = xoffInit + (i << 1);
    y[bitrevIndex[i] - 1].re = x[iy];
    y[bitrevIndex[i] - 1].im = x[iy + 1];
  }
  if (!tst) {
    istart = bitrevIndex[static_cast<int>(temp_re)] - 1;
    y[istart].re = x[xoffInit + (static_cast<int>(temp_re) << 1)];
    y[istart].im = 0.0;
  }
  if (nRows > 1) {
    for (i = 0; i <= nRowsM2; i += 2) {
      temp_re_tmp = y[i + 1].re;
      temp_im_tmp = y[i + 1].im;
      y[i + 1].re = y[i].re - temp_re_tmp;
      y[i + 1].im = y[i].im - y[i + 1].im;
      y[i].re = y[i].re + temp_re_tmp;
      y[i].im = y[i].im + temp_im_tmp;
    }
  }
  hszCostab = 2;
  iy = 4;
  ju = ((k - 1) << 2) + 1;
  while (k > 0) {
    for (i = 0; i < ju; i += iy) {
      nRowsM2 = i + hszCostab;
      temp_re = y[nRowsM2].re;
      temp_im = y[nRowsM2].im;
      y[nRowsM2].re = y[i].re - temp_re;
      y[nRowsM2].im = y[i].im - temp_im;
      y[i].re = y[i].re + temp_re;
      y[i].im = y[i].im + temp_im;
    }
    istart = 1;
    for (j = k; j < nRowsD2; j += k) {
      temp2_re = hcostab[j];
      temp2_im = hsintab[j];
      i = istart;
      nRows = istart + ju;
      while (i < nRows) {
        nRowsM2 = i + hszCostab;
        temp_re_tmp = y[nRowsM2].im;
        y_re_tmp = y[nRowsM2].re;
        temp_re = temp2_re * y_re_tmp - temp2_im * temp_re_tmp;
        temp_im = temp2_re * temp_re_tmp + temp2_im * y_re_tmp;
        y[nRowsM2].re = y[i].re - temp_re;
        y[nRowsM2].im = y[i].im - temp_im;
        y[i].re = y[i].re + temp_re;
        y[i].im = y[i].im + temp_im;
        i += iy;
      }
      istart++;
    }
    k >>= 1;
    hszCostab = iy;
    iy += iy;
    ju -= hszCostab;
  }
  hszCostab = (static_cast<int>(z_tmp) + (static_cast<int>(z_tmp) < 0)) >> 1;
  temp_re_tmp = y[0].re;
  temp_im_tmp = y[0].im;
  y[0].re =
      0.5 * ((temp_re_tmp * reconVar1[0].re - temp_im_tmp * reconVar1[0].im) +
             (temp_re_tmp * reconVar2[0].re - -temp_im_tmp * reconVar2[0].im));
  y[0].im =
      0.5 * ((temp_re_tmp * reconVar1[0].im + temp_im_tmp * reconVar1[0].re) +
             (temp_re_tmp * reconVar2[0].im + -temp_im_tmp * reconVar2[0].re));
  y[static_cast<int>(z_tmp)].re =
      0.5 * ((temp_re_tmp * reconVar2[0].re - temp_im_tmp * reconVar2[0].im) +
             (temp_re_tmp * reconVar1[0].re - -temp_im_tmp * reconVar1[0].im));
  y[static_cast<int>(z_tmp)].im =
      0.5 * ((temp_re_tmp * reconVar2[0].im + temp_im_tmp * reconVar2[0].re) +
             (temp_re_tmp * reconVar1[0].im + -temp_im_tmp * reconVar1[0].re));
  for (i = 2; i <= hszCostab; i++) {
    double temp2_im_tmp;
    temp_re_tmp = y[i - 1].re;
    temp_im_tmp = y[i - 1].im;
    istart = wrapIndex[i - 1];
    temp2_im = y[istart - 1].re;
    temp2_im_tmp = y[istart - 1].im;
    y_re_tmp = reconVar1[i - 1].im;
    b_y_re_tmp = reconVar1[i - 1].re;
    c_y_re_tmp = reconVar2[i - 1].im;
    d_y_re_tmp = reconVar2[i - 1].re;
    y[i - 1].re = 0.5 * ((temp_re_tmp * b_y_re_tmp - temp_im_tmp * y_re_tmp) +
                         (temp2_im * d_y_re_tmp - -temp2_im_tmp * c_y_re_tmp));
    y[i - 1].im = 0.5 * ((temp_re_tmp * y_re_tmp + temp_im_tmp * b_y_re_tmp) +
                         (temp2_im * c_y_re_tmp + -temp2_im_tmp * d_y_re_tmp));
    iy = (static_cast<int>(z_tmp) + i) - 1;
    y[iy].re = 0.5 * ((temp_re_tmp * d_y_re_tmp - temp_im_tmp * c_y_re_tmp) +
                      (temp2_im * b_y_re_tmp - -temp2_im_tmp * y_re_tmp));
    y[iy].im = 0.5 * ((temp_re_tmp * c_y_re_tmp + temp_im_tmp * d_y_re_tmp) +
                      (temp2_im * y_re_tmp + -temp2_im_tmp * b_y_re_tmp));
    temp_im = reconVar1[istart - 1].im;
    temp_re = reconVar1[istart - 1].re;
    y_re_tmp = reconVar2[istart - 1].im;
    temp2_re = reconVar2[istart - 1].re;
    y[istart - 1].re =
        0.5 * ((temp2_im * temp_re - temp2_im_tmp * temp_im) +
               (temp_re_tmp * temp2_re - -temp_im_tmp * y_re_tmp));
    y[istart - 1].im =
        0.5 * ((temp2_im * temp_im + temp2_im_tmp * temp_re) +
               (temp_re_tmp * y_re_tmp + -temp_im_tmp * temp2_re));
    istart = (istart + static_cast<int>(z_tmp)) - 1;
    y[istart].re = 0.5 * ((temp2_im * temp2_re - temp2_im_tmp * y_re_tmp) +
                          (temp_re_tmp * temp_re - -temp_im_tmp * temp_im));
    y[istart].im = 0.5 * ((temp2_im * y_re_tmp + temp2_im_tmp * temp2_re) +
                          (temp_re_tmp * temp_im + -temp_im_tmp * temp_re));
  }
  if (hszCostab != 0) {
    temp_re_tmp = y[hszCostab].re;
    temp_im_tmp = y[hszCostab].im;
    y_re_tmp = reconVar1[hszCostab].im;
    b_y_re_tmp = reconVar1[hszCostab].re;
    c_y_re_tmp = reconVar2[hszCostab].im;
    d_y_re_tmp = reconVar2[hszCostab].re;
    temp_re = temp_re_tmp * d_y_re_tmp;
    temp2_re = temp_re_tmp * b_y_re_tmp;
    y[hszCostab].re = 0.5 * ((temp2_re - temp_im_tmp * y_re_tmp) +
                             (temp_re - -temp_im_tmp * c_y_re_tmp));
    temp2_im = temp_re_tmp * c_y_re_tmp;
    temp_im = temp_re_tmp * y_re_tmp;
    y[hszCostab].im = 0.5 * ((temp_im + temp_im_tmp * b_y_re_tmp) +
                             (temp2_im + -temp_im_tmp * d_y_re_tmp));
    istart = static_cast<int>(z_tmp) + hszCostab;
    y[istart].re = 0.5 * ((temp_re - temp_im_tmp * c_y_re_tmp) +
                          (temp2_re - -temp_im_tmp * y_re_tmp));
    y[istart].im = 0.5 * ((temp2_im + temp_im_tmp * d_y_re_tmp) +
                          (temp_im + -temp_im_tmp * b_y_re_tmp));
  }
}

void FFTImplementationCallback::r2br_r2dit_trig_impl(
    const ::coder::array<creal_T, 1U> &x, int unsigned_nRows,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab, ::coder::array<creal_T, 1U> &y)
{
  double temp_im;
  double temp_re;
  double temp_re_tmp;
  double twid_re;
  int i;
  int iDelta2;
  int iheight;
  int iy;
  int ju;
  int k;
  int nRowsD2;
  y.set_size(unsigned_nRows);
  if (unsigned_nRows > x.size(0)) {
    y.set_size(unsigned_nRows);
    for (iy = 0; iy < unsigned_nRows; iy++) {
      y[iy].re = 0.0;
      y[iy].im = 0.0;
    }
  }
  iDelta2 = x.size(0);
  if (iDelta2 > unsigned_nRows) {
    iDelta2 = unsigned_nRows;
  }
  iheight = unsigned_nRows - 2;
  nRowsD2 = (unsigned_nRows + (unsigned_nRows < 0)) >> 1;
  k = (nRowsD2 + (nRowsD2 < 0)) >> 1;
  iy = 0;
  ju = 0;
  for (i = 0; i <= iDelta2 - 2; i++) {
    bool tst;
    y[iy] = x[i];
    iy = unsigned_nRows;
    tst = true;
    while (tst) {
      iy >>= 1;
      ju ^= iy;
      tst = ((ju & iy) == 0);
    }
    iy = ju;
  }
  y[iy] = x[iDelta2 - 1];
  if (unsigned_nRows > 1) {
    for (i = 0; i <= iheight; i += 2) {
      temp_re_tmp = y[i + 1].re;
      temp_im = y[i + 1].im;
      temp_re = y[i].re;
      twid_re = y[i].im;
      y[i + 1].re = temp_re - temp_re_tmp;
      y[i + 1].im = twid_re - temp_im;
      y[i].re = temp_re + temp_re_tmp;
      y[i].im = twid_re + temp_im;
    }
  }
  iy = 2;
  iDelta2 = 4;
  iheight = ((k - 1) << 2) + 1;
  while (k > 0) {
    int b_temp_re_tmp;
    for (i = 0; i < iheight; i += iDelta2) {
      b_temp_re_tmp = i + iy;
      temp_re = y[b_temp_re_tmp].re;
      temp_im = y[b_temp_re_tmp].im;
      y[b_temp_re_tmp].re = y[i].re - temp_re;
      y[b_temp_re_tmp].im = y[i].im - temp_im;
      y[i].re = y[i].re + temp_re;
      y[i].im = y[i].im + temp_im;
    }
    ju = 1;
    for (int j{k}; j < nRowsD2; j += k) {
      double twid_im;
      int ihi;
      twid_re = costab[j];
      twid_im = sintab[j];
      i = ju;
      ihi = ju + iheight;
      while (i < ihi) {
        b_temp_re_tmp = i + iy;
        temp_re_tmp = y[b_temp_re_tmp].im;
        temp_im = y[b_temp_re_tmp].re;
        temp_re = twid_re * temp_im - twid_im * temp_re_tmp;
        temp_im = twid_re * temp_re_tmp + twid_im * temp_im;
        y[b_temp_re_tmp].re = y[i].re - temp_re;
        y[b_temp_re_tmp].im = y[i].im - temp_im;
        y[i].re = y[i].re + temp_re;
        y[i].im = y[i].im + temp_im;
        i += iDelta2;
      }
      ju++;
    }
    k >>= 1;
    iy = iDelta2;
    iDelta2 += iDelta2;
    iheight -= iy;
  }
}

void FFTImplementationCallback::dobluesteinfft(
    const ::coder::array<double, 2U> &x, int n2blue, int nfft,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab,
    const ::coder::array<double, 2U> &sintabinv, ::coder::array<creal_T, 2U> &y)
{
  array<creal_T, 1U> fv;
  array<creal_T, 1U> fy;
  array<creal_T, 1U> r;
  array<creal_T, 1U> wwc;
  double b_temp_re_tmp;
  double temp_im;
  double temp_re;
  double twid_im;
  double twid_re;
  int b_i;
  int b_k;
  int b_y;
  int i;
  int ihi;
  int iy;
  int j;
  int ju;
  int minNrowsNx;
  int nInt2m1;
  int nRowsD2;
  int temp_re_tmp;
  int xoff;
  bool tst;
  if ((nfft != 1) && ((nfft & 1) == 0)) {
    int nInt2;
    int nRows;
    int rt;
    nRows = (nfft + (nfft < 0)) >> 1;
    nInt2m1 = (nRows + nRows) - 1;
    wwc.set_size(nInt2m1);
    rt = 0;
    wwc[nRows - 1].re = 1.0;
    wwc[nRows - 1].im = 0.0;
    nInt2 = nRows << 1;
    for (int k{0}; k <= nRows - 2; k++) {
      double nt_im;
      double nt_re;
      b_y = ((k + 1) << 1) - 1;
      if (nInt2 - rt <= b_y) {
        rt += b_y - nInt2;
      } else {
        rt += b_y;
      }
      nt_im = -3.1415926535897931 * static_cast<double>(rt) /
              static_cast<double>(nRows);
      if (nt_im == 0.0) {
        nt_re = 1.0;
        nt_im = 0.0;
      } else {
        nt_re = std::cos(nt_im);
        nt_im = std::sin(nt_im);
      }
      i = (nRows - k) - 2;
      wwc[i].re = nt_re;
      wwc[i].im = -nt_im;
    }
    i = nInt2m1 - 1;
    for (int k{i}; k >= nRows; k--) {
      wwc[k] = wwc[(nInt2m1 - k) - 1];
    }
  } else {
    int nInt2;
    int rt;
    nInt2m1 = (nfft + nfft) - 1;
    wwc.set_size(nInt2m1);
    rt = 0;
    wwc[nfft - 1].re = 1.0;
    wwc[nfft - 1].im = 0.0;
    nInt2 = nfft << 1;
    for (int k{0}; k <= nfft - 2; k++) {
      double nt_im;
      double nt_re;
      b_y = ((k + 1) << 1) - 1;
      if (nInt2 - rt <= b_y) {
        rt += b_y - nInt2;
      } else {
        rt += b_y;
      }
      nt_im = -3.1415926535897931 * static_cast<double>(rt) /
              static_cast<double>(nfft);
      if (nt_im == 0.0) {
        nt_re = 1.0;
        nt_im = 0.0;
      } else {
        nt_re = std::cos(nt_im);
        nt_im = std::sin(nt_im);
      }
      i = (nfft - k) - 2;
      wwc[i].re = nt_re;
      wwc[i].im = -nt_im;
    }
    i = nInt2m1 - 1;
    for (int k{i}; k >= nfft; k--) {
      wwc[k] = wwc[(nInt2m1 - k) - 1];
    }
  }
  nInt2m1 = x.size(0);
  y.set_size(nfft, x.size(1));
  if (nfft > x.size(0)) {
    y.set_size(nfft, x.size(1));
    b_y = nfft * x.size(1);
    for (i = 0; i < b_y; i++) {
      y[i].re = 0.0;
      y[i].im = 0.0;
    }
  }
  b_y = x.size(1) - 1;
#pragma omp parallel for num_threads(omp_get_max_threads()) private(           \
    fv, fy, r, xoff, ju, minNrowsNx, iy, b_k, temp_re_tmp, j, nRowsD2, b_i,    \
    tst, b_temp_re_tmp, temp_im, twid_im, temp_re, twid_re, ihi)

  for (int chan = 0; chan <= b_y; chan++) {
    xoff = chan * nInt2m1;
    r.set_size(nfft);
    if (nfft > x.size(0)) {
      r.set_size(nfft);
      for (ju = 0; ju < nfft; ju++) {
        r[ju].re = 0.0;
        r[ju].im = 0.0;
      }
    }
    if ((n2blue != 1) && ((nfft & 1) == 0)) {
      FFTImplementationCallback::doHalfLengthBluestein(
          x, xoff, r, x.size(0), nfft, n2blue, wwc, costab, sintab, costab,
          sintabinv);
    } else {
      minNrowsNx = x.size(0);
      if (nfft <= minNrowsNx) {
        minNrowsNx = nfft;
      }
      for (b_k = 0; b_k < minNrowsNx; b_k++) {
        temp_re_tmp = (nfft + b_k) - 1;
        ju = xoff + b_k;
        r[b_k].re = wwc[temp_re_tmp].re * x[ju];
        r[b_k].im = wwc[temp_re_tmp].im * -x[ju];
      }
      ju = minNrowsNx + 1;
      for (b_k = ju; b_k <= nfft; b_k++) {
        r[b_k - 1].re = 0.0;
        r[b_k - 1].im = 0.0;
      }
      fy.set_size(n2blue);
      if (n2blue > r.size(0)) {
        fy.set_size(n2blue);
        for (ju = 0; ju < n2blue; ju++) {
          fy[ju].re = 0.0;
          fy[ju].im = 0.0;
        }
      }
      iy = r.size(0);
      j = n2blue;
      if (iy <= n2blue) {
        j = iy;
      }
      minNrowsNx = n2blue - 2;
      nRowsD2 = (n2blue + (n2blue < 0)) >> 1;
      b_k = (nRowsD2 + (nRowsD2 < 0)) >> 1;
      iy = 0;
      ju = 0;
      for (b_i = 0; b_i <= j - 2; b_i++) {
        fy[iy] = r[b_i];
        xoff = n2blue;
        tst = true;
        while (tst) {
          xoff >>= 1;
          ju ^= xoff;
          tst = ((ju & xoff) == 0);
        }
        iy = ju;
      }
      fy[iy] = r[j - 1];
      if (n2blue > 1) {
        for (b_i = 0; b_i <= minNrowsNx; b_i += 2) {
          b_temp_re_tmp = fy[b_i + 1].re;
          temp_im = fy[b_i + 1].im;
          twid_im = fy[b_i].re;
          temp_re = fy[b_i].im;
          fy[b_i + 1].re = twid_im - b_temp_re_tmp;
          fy[b_i + 1].im = temp_re - temp_im;
          fy[b_i].re = twid_im + b_temp_re_tmp;
          fy[b_i].im = temp_re + temp_im;
        }
      }
      xoff = 2;
      minNrowsNx = 4;
      iy = ((b_k - 1) << 2) + 1;
      while (b_k > 0) {
        for (b_i = 0; b_i < iy; b_i += minNrowsNx) {
          temp_re_tmp = b_i + xoff;
          temp_re = fy[temp_re_tmp].re;
          temp_im = fy[temp_re_tmp].im;
          fy[temp_re_tmp].re = fy[b_i].re - temp_re;
          fy[temp_re_tmp].im = fy[b_i].im - temp_im;
          fy[b_i].re = fy[b_i].re + temp_re;
          fy[b_i].im = fy[b_i].im + temp_im;
        }
        ju = 1;
        for (j = b_k; j < nRowsD2; j += b_k) {
          twid_re = costab[j];
          twid_im = sintab[j];
          b_i = ju;
          ihi = ju + iy;
          while (b_i < ihi) {
            temp_re_tmp = b_i + xoff;
            b_temp_re_tmp = fy[temp_re_tmp].im;
            temp_im = fy[temp_re_tmp].re;
            temp_re = twid_re * temp_im - twid_im * b_temp_re_tmp;
            temp_im = twid_re * b_temp_re_tmp + twid_im * temp_im;
            fy[temp_re_tmp].re = fy[b_i].re - temp_re;
            fy[temp_re_tmp].im = fy[b_i].im - temp_im;
            fy[b_i].re = fy[b_i].re + temp_re;
            fy[b_i].im = fy[b_i].im + temp_im;
            b_i += minNrowsNx;
          }
          ju++;
        }
        b_k >>= 1;
        xoff = minNrowsNx;
        minNrowsNx += minNrowsNx;
        iy -= xoff;
      }
      FFTImplementationCallback::r2br_r2dit_trig_impl(wwc, n2blue, costab,
                                                      sintab, fv);
      iy = fy.size(0);
      for (ju = 0; ju < iy; ju++) {
        twid_im = fy[ju].re;
        temp_im = fv[ju].im;
        temp_re = fy[ju].im;
        twid_re = fv[ju].re;
        fy[ju].re = twid_im * twid_re - temp_re * temp_im;
        fy[ju].im = twid_im * temp_im + temp_re * twid_re;
      }
      FFTImplementationCallback::r2br_r2dit_trig_impl(fy, n2blue, costab,
                                                      sintabinv, fv);
      if (fv.size(0) > 1) {
        temp_im = 1.0 / static_cast<double>(fv.size(0));
        iy = fv.size(0);
        for (ju = 0; ju < iy; ju++) {
          fv[ju].re = temp_im * fv[ju].re;
          fv[ju].im = temp_im * fv[ju].im;
        }
      }
      ju = wwc.size(0);
      for (b_k = nfft; b_k <= ju; b_k++) {
        temp_im = wwc[b_k - 1].re;
        temp_re = fv[b_k - 1].im;
        twid_re = wwc[b_k - 1].im;
        twid_im = fv[b_k - 1].re;
        iy = b_k - nfft;
        r[iy].re = temp_im * twid_im + twid_re * temp_re;
        r[iy].im = temp_im * temp_re - twid_re * twid_im;
      }
    }
    iy = r.size(0);
    for (ju = 0; ju < iy; ju++) {
      y[ju + y.size(0) * chan] = r[ju];
    }
  }
}

void FFTImplementationCallback::r2br_r2dit_trig(
    const ::coder::array<double, 2U> &x, int n1_unsigned,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab, ::coder::array<creal_T, 2U> &y)
{
  array<creal_T, 1U> r;
  int i1;
  int loop_ub;
  int nrows;
  int u0;
  int xoff;
  nrows = x.size(0);
  y.set_size(n1_unsigned, x.size(1));
  if (n1_unsigned > x.size(0)) {
    y.set_size(n1_unsigned, x.size(1));
    loop_ub = n1_unsigned * x.size(1);
    for (int i{0}; i < loop_ub; i++) {
      y[i].re = 0.0;
      y[i].im = 0.0;
    }
  }
  loop_ub = x.size(1) - 1;
#pragma omp parallel for num_threads(omp_get_max_threads()) private(r, xoff,   \
                                                                    i1, u0)

  for (int chan = 0; chan <= loop_ub; chan++) {
    xoff = chan * nrows;
    r.set_size(n1_unsigned);
    if (n1_unsigned > x.size(0)) {
      r.set_size(n1_unsigned);
      for (i1 = 0; i1 < n1_unsigned; i1++) {
        r[i1].re = 0.0;
        r[i1].im = 0.0;
      }
    }
    if (n1_unsigned != 1) {
      FFTImplementationCallback::doHalfLengthRadix2(x, xoff, r, n1_unsigned,
                                                    costab, sintab);
    } else {
      u0 = x.size(0);
      if (u0 > 1) {
        u0 = 1;
      }
      r[0].re = x[(xoff + u0) - 1];
      r[0].im = 0.0;
    }
    u0 = r.size(0);
    for (i1 = 0; i1 < u0; i1++) {
      y[i1 + y.size(0) * chan] = r[i1];
    }
  }
}

} // namespace fft
} // namespace internal
} // namespace coder

// End of code generation (FFTImplementationCallback.cpp)
