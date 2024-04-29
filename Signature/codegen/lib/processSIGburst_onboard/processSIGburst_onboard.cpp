//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard.cpp
//
// Code generation for function 'processSIGburst_onboard'
//

// Include files
#include "processSIGburst_onboard.h"
#include "combineVectorElements.h"
#include "eof.h"
#include "interp1.h"
#include "mean.h"
#include "mldivide.h"
#include "movmedian.h"
#include "mtimes.h"
#include "nanmean.h"
#include "permute.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include "std.h"
#include "coder_array.h"
#include <algorithm>
#include <cmath>

// Function Declarations
static void minus(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2);

static void minus(coder::array<double, 3U> &in1,
                  const coder::array<double, 3U> &in2);

static double rt_powd_snf(double u0, double u1);

// Function Definitions
static void minus(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in2;
  int aux_0_1;
  int aux_1_1;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in1.size(1) == 1) {
    loop_ub = in2.size(1);
  } else {
    loop_ub = in1.size(1);
  }
  b_in2.set_size(128, loop_ub);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_1 = (in1.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (int i{0}; i < loop_ub; i++) {
    for (int i1{0}; i1 < 128; i1++) {
      b_in2[i1 + 128 * i] = in2[i1 + 128 * aux_0_1] - in1[i1 + 128 * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(128, b_in2.size(1));
  loop_ub = b_in2.size(1);
  for (int i{0}; i < loop_ub; i++) {
    for (int i1{0}; i1 < 128; i1++) {
      in1[i1 + 128 * i] = b_in2[i1 + 128 * i];
    }
  }
}

static void minus(coder::array<double, 3U> &in1,
                  const coder::array<double, 3U> &in2)
{
  coder::array<double, 3U> b_in1;
  int aux_0_2;
  int aux_1_2;
  int loop_ub;
  int stride_0_2;
  int stride_1_2;
  if (in2.size(2) == 1) {
    loop_ub = in1.size(2);
  } else {
    loop_ub = in2.size(2);
  }
  b_in1.set_size(128, 128, loop_ub);
  stride_0_2 = (in1.size(2) != 1);
  stride_1_2 = (in2.size(2) != 1);
  aux_0_2 = 0;
  aux_1_2 = 0;
  for (int i{0}; i < loop_ub; i++) {
    for (int i1{0}; i1 < 128; i1++) {
      for (int i2{0}; i2 < 128; i2++) {
        b_in1[(i2 + 128 * i1) + 16384 * i] =
            in1[(i2 + 128 * i1) + 16384 * aux_0_2] -
            in2[(i2 + 128 * i1) + 16384 * aux_1_2];
      }
    }
    aux_1_2 += stride_1_2;
    aux_0_2 += stride_0_2;
  }
  in1.set_size(128, 128, b_in1.size(2));
  loop_ub = b_in1.size(2);
  for (int i{0}; i < loop_ub; i++) {
    for (int i1{0}; i1 < 128; i1++) {
      for (int i2{0}; i2 < 128; i2++) {
        in1[(i2 + 128 * i1) + 16384 * i] = b_in1[(i2 + 128 * i1) + 16384 * i];
      }
    }
  }
}

static double rt_powd_snf(double u0, double u1)
{
  double y;
  if (std::isnan(u0) || std::isnan(u1)) {
    y = rtNaN;
  } else {
    double d;
    double d1;
    d = std::abs(u0);
    d1 = std::abs(u1);
    if (std::isinf(u1)) {
      if (d == 1.0) {
        y = 1.0;
      } else if (d > 1.0) {
        if (u1 > 0.0) {
          y = rtInf;
        } else {
          y = 0.0;
        }
      } else if (u1 > 0.0) {
        y = 0.0;
      } else {
        y = rtInf;
      }
    } else if (d1 == 0.0) {
      y = 1.0;
    } else if (d1 == 1.0) {
      if (u1 > 0.0) {
        y = u0;
      } else {
        y = 1.0 / u0;
      }
    } else if (u1 == 2.0) {
      y = u0 * u0;
    } else if ((u1 == 0.5) && (u0 >= 0.0)) {
      y = std::sqrt(u0);
    } else if ((u0 < 0.0) && (u1 > std::floor(u1))) {
      y = rtNaN;
    } else {
      y = std::pow(u0, u1);
    }
  }
  return y;
}

void processSIGburst_onboard(const coder::array<double, 2U> &wraw, double cs,
                             double dz, double bz, double neoflp, double rmin,
                             double rmax, double nzfit,
                             const coder::array<char, 2U> &avgtype,
                             const coder::array<char, 2U> &fittype,
                             double eps[128])
{
  static creal_T eofs[16384];
  static double D[16384];
  static double R[16384];
  static double Z0[16384];
  static double Z2[16384];
  static short tmp_data[16384];
  static const char cv1[7]{'l', 'o', 'g', 'm', 'e', 'a', 'n'};
  static const char cv3[6]{'l', 'i', 'n', 'e', 'a', 'r'};
  static const char cv2[5]{'c', 'u', 'b', 'i', 'c'};
  static const char cv[4]{'m', 'e', 'a', 'n'};
  static const char cv4[3]{'l', 'o', 'g'};
  coder::array<creal_T, 2U> alpha;
  coder::array<creal_T, 2U> b_alpha;
  coder::array<creal_T, 2U> b_eofs;
  coder::array<creal_T, 2U> r3;
  coder::array<double, 3U> b_dW;
  coder::array<double, 3U> c_y;
  coder::array<double, 3U> dW;
  coder::array<double, 2U> A;
  coder::array<double, 2U> G;
  coder::array<double, 2U> b_A;
  coder::array<double, 2U> b_G;
  coder::array<double, 2U> b_wfilt;
  coder::array<double, 2U> c_G;
  coder::array<double, 2U> d_G;
  coder::array<double, 2U> wfilt;
  coder::array<double, 2U> y;
  coder::array<double, 1U> Di;
  coder::array<double, 1U> b_x1;
  coder::array<double, 1U> x1;
  coder::array<int, 2U> r;
  coder::array<int, 2U> r1;
  coder::array<int, 1U> iidx;
  coder::array<int, 1U> r2;
  coder::array<bool, 3U> r4;
  coder::array<bool, 2U> ispike;
  creal_T unusedExpr[128];
  double b_z[128];
  double z[128];
  double b_y[127];
  double C[2];
  double d;
  double tmp2;
  double work;
  int boffset;
  int exitg2;
  int i;
  int ibmat;
  int ibtile;
  int idx;
  int nx_tmp;
  int trueCount;
  short b_tmp_data[16384];
  short c_tmp_data[16384];
  short d_tmp_data[16384];
  short e_tmp_data[16384];
  bool b_bool;
  //  w = nbin x nping HR velocity data
  //  cs = 1 x nping sound speed, from HR data
  //  dz = 1 x 1 bin size (m);
  //  bz = 1 x 1 blanking distance (m);
  //  neoflp = 1 x 1 number of low-mode EOFs to filter from the data;
  //  ONBOARD NOTES:
  //  No plotting
  //  Replace 'opt' structure input with variables
  //  Burst variables are now inputs
  //  No need to check dimensions as prespecified
  //  Don't interpolate through bad pings, as those are tossed before computing
  //  eps N pings + N z-bins
  for (i = 0; i < 128; i++) {
    z[i] = (bz + 0.2) + dz * (static_cast<double>(i) + 1.0);
  }
  // %%%%%% Despike %%%%%%%
  //  Find Spikes (phase-shift threshold, Shcherbina 2018)
  //  m, pulse distance
  //  Hz, pulse carrier frequency (1 MHz for Sig 1000)
  work = nanmean(cs);
  //  m/s
  //  1 m
  //  Identify Spikes
  coder::movmedian(wraw, std::round(1.0 / dz), wfilt);
  //  was medfilt1
  if (wraw.size(1) == wfilt.size(1)) {
    ibtile = wraw.size(1) << 7;
    wfilt.set_size(128, wraw.size(1));
    for (i = 0; i < ibtile; i++) {
      wfilt[i] = wraw[i] - wfilt[i];
    }
  } else {
    minus(wfilt, wraw);
  }
  nx_tmp = wfilt.size(1) << 7;
  y.set_size(128, wfilt.size(1));
  for (int k{0}; k < nx_tmp; k++) {
    y[k] = std::abs(wfilt[k]);
  }
  ispike.set_size(128, y.size(1));
  work = work * work / (4.0E+6 * (bz + dz * 128.0)) / 2.0;
  for (i = 0; i < nx_tmp; i++) {
    ispike[i] = (y[i] > work);
  }
  //  Fill with linear interpolation
  wfilt.set_size(128, wraw.size(1));
  ibtile = wraw.size(1) << 7;
  for (i = 0; i < ibtile; i++) {
    wfilt[i] = rtNaN;
  }
  i = wraw.size(1);
  for (ibmat = 0; ibmat < i; ibmat++) {
    double igood_data[128];
    unsigned char i_data[128];
    bool x[128];
    bool exitg1;
    for (boffset = 0; boffset < 128; boffset++) {
      x[boffset] = !ispike[boffset + 128 * ibmat];
    }
    idx = 0;
    ibtile = 0;
    exitg1 = false;
    while ((!exitg1) && (ibtile < 128)) {
      if (x[ibtile]) {
        idx++;
        i_data[idx - 1] = static_cast<unsigned char>(ibtile + 1);
        if (idx >= 128) {
          exitg1 = true;
        } else {
          ibtile++;
        }
      } else {
        ibtile++;
      }
    }
    if (idx < 1) {
      idx = 0;
    }
    for (boffset = 0; boffset < idx; boffset++) {
      igood_data[boffset] = i_data[boffset];
    }
    if (idx > 3) {
      double wraw_data[128];
      for (boffset = 0; boffset < idx; boffset++) {
        wraw_data[boffset] =
            wraw[(static_cast<int>(igood_data[boffset]) + 128 * ibmat) - 1];
      }
      coder::interp1(igood_data, idx, wraw_data, idx, b_z);
      for (boffset = 0; boffset < 128; boffset++) {
        wfilt[boffset + 128 * ibmat] = b_z[boffset];
      }
    }
  }
  // %%%%% EOF High-pass %%%%%%
  //  Identify badpings with greater than 50% spikes
  //
  //  Compute EOFs from good pings
  coder::combineVectorElements(ispike, r);
  idx = r.size(1) - 1;
  trueCount = 0;
  for (int b_i{0}; b_i <= idx; b_i++) {
    if (!(static_cast<double>(r[b_i]) / 128.0 > 0.5)) {
      trueCount++;
    }
  }
  r1.set_size(1, trueCount);
  boffset = 0;
  for (int b_i{0}; b_i <= idx; b_i++) {
    if (!(static_cast<double>(r[b_i]) / 128.0 > 0.5)) {
      r1[boffset] = b_i;
      boffset++;
    }
  }
  b_wfilt.set_size(r1.size(1), 128);
  ibtile = r1.size(1);
  for (i = 0; i < 128; i++) {
    for (boffset = 0; boffset < ibtile; boffset++) {
      b_wfilt[boffset + b_wfilt.size(0) * i] = wfilt[i + 128 * r1[boffset]];
    }
  }
  eof(b_wfilt, eofs, alpha, b_z, unusedExpr);
  //  Reconstruct w/high-mode EOFs
  C[1] = wfilt.size(1);
  i = static_cast<int>(C[1]);
  wfilt.set_size(128, i);
  ibtile = i << 7;
  for (i = 0; i < ibtile; i++) {
    wfilt[i] = rtNaN;
  }
  if (neoflp + 1.0 > 128.0) {
    i = 0;
    boffset = 0;
    ibmat = 0;
  } else {
    i = static_cast<int>(neoflp + 1.0) - 1;
    boffset = 128;
    ibmat = static_cast<int>(neoflp + 1.0) - 1;
  }
  r2.set_size(r1.size(1));
  ibtile = r1.size(1);
  for (idx = 0; idx < ibtile; idx++) {
    r2[idx] = r1[idx];
  }
  ibtile = boffset - i;
  b_eofs.set_size(128, ibtile);
  for (boffset = 0; boffset < ibtile; boffset++) {
    for (idx = 0; idx < 128; idx++) {
      b_eofs[idx + 128 * boffset] = eofs[idx + ((i + boffset) << 7)];
    }
  }
  b_alpha.set_size(alpha.size(0), ibtile);
  for (i = 0; i < ibtile; i++) {
    idx = alpha.size(0);
    for (boffset = 0; boffset < idx; boffset++) {
      b_alpha[boffset + b_alpha.size(0) * i] =
          alpha[boffset + alpha.size(0) * (ibmat + i)];
    }
  }
  coder::internal::blas::mtimes(b_eofs, b_alpha, r3);
  ibtile = r2.size(0);
  for (i = 0; i < ibtile; i++) {
    for (boffset = 0; boffset < 128; boffset++) {
      wfilt[boffset + 128 * r2[i]] = r3[boffset + 128 * i].re;
    }
  }
  //  Remove spikes
  idx = nx_tmp - 1;
  for (int b_i{0}; b_i <= idx; b_i++) {
    if (ispike[b_i]) {
      wfilt[b_i] = rtNaN;
    }
  }
  // %%%%% Compute Dissipation Rate %%%%%%
  //  Matrices of all possible data pair separation distances (R), and
  //  corresponding mean vertical position (Z0)
  for (i = 0; i < 128; i++) {
    b_z[i] = (bz + 0.2) + dz * (static_cast<double>(i) + 1.0);
  }
  idx = 1;
  work = (bz + 0.2) + dz;
  for (ibtile = 0; ibtile < 127; ibtile++) {
    tmp2 = work;
    work = (bz + 0.2) + dz * (static_cast<double>(idx) + 1.0);
    b_y[ibtile] = work - tmp2;
    idx++;
  }
  work = b_y[0];
  for (int k{0}; k < 126; k++) {
    work += b_y[k + 1];
  }
  dz = work / 127.0;
  // R = round(R,2);
  for (i = 0; i < 128; i++) {
    for (boffset = 0; boffset < 128; boffset++) {
      R[boffset + (i << 7)] = (b_z[i] - b_z[boffset]) * 100.0;
    }
  }
  for (int k{0}; k < 16384; k++) {
    R[k] = std::round(R[k]) / 100.0;
  }
  for (ibmat = 0; ibmat < 128; ibmat++) {
    std::copy(&z[0], &z[128], &Z2[ibmat * 128]);
    for (int b_i{0}; b_i < 128; b_i++) {
      idx = b_i + (ibmat << 7);
      Z0[idx] = z[ibmat];
    }
  }
  for (i = 0; i < 16384; i++) {
    Z0[i] = (Z0[i] + Z2[i]) / 2.0;
  }
  //  Matrices of all possible data pair velocity differences for each ping.
  coder::mean(wfilt, b_z);
  y.set_size(128, wfilt.size(1));
  ibtile = wfilt.size(1);
  for (i = 0; i < ibtile; i++) {
    for (boffset = 0; boffset < 128; boffset++) {
      y[boffset + 128 * i] = wfilt[boffset + 128 * i] - b_z[boffset];
    }
  }
  wfilt.set_size(128, y.size(1));
  ibtile = y.size(1);
  for (i = 0; i < ibtile; i++) {
    for (boffset = 0; boffset < 128; boffset++) {
      wfilt[boffset + 128 * i] = y[boffset + 128 * i];
    }
  }
  dW.set_size(128, wfilt.size(1), 128);
  idx = wfilt.size(1);
  for (trueCount = 0; trueCount < 128; trueCount++) {
    ibtile = trueCount * (idx << 7) - 1;
    for (nx_tmp = 0; nx_tmp < idx; nx_tmp++) {
      boffset = nx_tmp << 7;
      ibmat = ibtile + boffset;
      for (int k{0}; k < 128; k++) {
        dW[(ibmat + k) + 1] = wfilt[boffset + k];
      }
    }
  }
  coder::permute(dW, b_dW);
  coder::b_permute(dW, c_y);
  if (b_dW.size(2) == c_y.size(2)) {
    ibtile = b_dW.size(2) << 14;
    b_dW.set_size(128, 128, b_dW.size(2));
    for (i = 0; i < ibtile; i++) {
      b_dW[i] = b_dW[i] - c_y[i];
    }
  } else {
    minus(b_dW, c_y);
  }
  coder::b_std(b_dW, Z2);
  for (i = 0; i < 16384; i++) {
    Z2[i] *= 5.0;
  }
  nx_tmp = b_dW.size(2) << 14;
  c_y.set_size(128, 128, b_dW.size(2));
  for (int k{0}; k < nx_tmp; k++) {
    c_y[k] = std::abs(b_dW[k]);
  }
  r4.set_size(128, 128, c_y.size(2));
  ibtile = c_y.size(2);
  for (i = 0; i < ibtile; i++) {
    for (boffset = 0; boffset < 128; boffset++) {
      for (ibmat = 0; ibmat < 128; ibmat++) {
        r4[(ibmat + 128 * boffset) + 16384 * i] =
            (c_y[(ibmat + 128 * boffset) + 16384 * i] >
             Z2[ibmat + (boffset << 7)]);
      }
    }
  }
  idx = nx_tmp - 1;
  for (int b_i{0}; b_i <= idx; b_i++) {
    if (r4[b_i]) {
      b_dW[b_i] = rtNaN;
    }
  }
  //  Take mean (or median, or mean-of-the-logs) squared velocity difference to
  //  get D(z,r)
  b_bool = false;
  if (avgtype.size(1) == 4) {
    idx = 0;
    do {
      exitg2 = 0;
      if (idx < 4) {
        if (avgtype[idx] != cv[idx]) {
          exitg2 = 1;
        } else {
          idx++;
        }
      } else {
        b_bool = true;
        exitg2 = 1;
      }
    } while (exitg2 == 0);
  }
  if (b_bool) {
    c_y.set_size(128, 128, b_dW.size(2));
    for (i = 0; i < nx_tmp; i++) {
      work = b_dW[i];
      c_y[i] = work * work;
    }
    coder::mean(c_y, D);
  } else {
    b_bool = false;
    if (avgtype.size(1) == 7) {
      idx = 0;
      do {
        exitg2 = 0;
        if (idx < 7) {
          if (avgtype[idx] != cv1[idx]) {
            exitg2 = 1;
          } else {
            idx++;
          }
        } else {
          b_bool = true;
          exitg2 = 1;
        }
      } while (exitg2 == 0);
    }
    if (b_bool) {
      c_y.set_size(128, 128, b_dW.size(2));
      for (i = 0; i < nx_tmp; i++) {
        work = b_dW[i];
        c_y[i] = work * work;
      }
      for (int k{0}; k < nx_tmp; k++) {
        c_y[k] = std::log10(c_y[k]);
      }
      coder::mean(c_y, Z2);
      for (int k{0}; k < 16384; k++) {
        D[k] = rt_powd_snf(10.0, Z2[k]);
      }
    }
  }
  // Fit structure function to theoretical curve
  for (i = 0; i < 128; i++) {
    eps[i] = rtNaN;
    b_z[i] = rtNaN;
  }
  d = 1.1 * nzfit * dz / 2.0;
  for (int ibin{0}; ibin < 128; ibin++) {
    bool ifit_data[16384];
    // Find points in z0 bin
    trueCount = 0;
    boffset = 0;
    work = z[ibin];
    for (int b_i{0}; b_i < 16384; b_i++) {
      tmp2 = Z0[b_i];
      if ((tmp2 >= work - d) && (tmp2 <= work + d)) {
        trueCount++;
        tmp_data[boffset] = static_cast<short>(b_i);
        boffset++;
      }
    }
    x1.set_size(trueCount);
    for (i = 0; i < trueCount; i++) {
      x1[i] = R[tmp_data[i]];
    }
    coder::internal::sort(x1, iidx);
    Di.set_size(iidx.size(0));
    ibtile = iidx.size(0);
    for (i = 0; i < ibtile; i++) {
      Di[i] = D[tmp_data[iidx[i] - 1]];
    }
    // Select points within specified separation scale range
    ibtile = x1.size(0);
    for (i = 0; i < ibtile; i++) {
      ifit_data[i] = ((x1[i] <= rmax) && (x1[i] >= rmin));
    }
    idx = x1.size(0);
    if (x1.size(0) == 0) {
      ibmat = 0;
    } else {
      ibmat = ((x1[0] <= rmax) && (x1[0] >= rmin));
      for (int k{2}; k <= idx; k++) {
        work = x1[k - 1];
        ibmat += ((work <= rmax) && (work >= rmin));
      }
    }
    idx = x1.size(0);
    if (x1.size(0) == 0) {
      ibtile = 0;
    } else {
      ibtile = ((x1[0] <= rmax) && (x1[0] >= rmin));
      for (int k{2}; k <= idx; k++) {
        work = x1[k - 1];
        ibtile += ((work <= rmax) && (work >= rmin));
      }
    }
    if (ibtile >= 3) {
      nx_tmp = x1.size(0) - 1;
      trueCount = 0;
      for (int b_i{0}; b_i <= nx_tmp; b_i++) {
        if ((x1[b_i] <= rmax) && (x1[b_i] >= rmin)) {
          trueCount++;
        }
      }
      boffset = 0;
      for (int b_i{0}; b_i <= nx_tmp; b_i++) {
        if ((x1[b_i] <= rmax) && (x1[b_i] >= rmin)) {
          work = x1[b_i];
          x1[boffset] = rt_powd_snf(work, 0.66666666666666663);
          boffset++;
        }
      }
      x1.set_size(trueCount);
      // Fit Structure function to theoretical curves
      b_bool = false;
      if (fittype.size(1) == 5) {
        idx = 0;
        do {
          exitg2 = 0;
          if (idx < 5) {
            if (fittype[idx] != cv2[idx]) {
              exitg2 = 1;
            } else {
              idx++;
            }
          } else {
            b_bool = true;
            exitg2 = 1;
          }
        } while (exitg2 == 0);
      }
      if (b_bool) {
        double b_C[9];
        double d_C[3];
        //  Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
        G.set_size(trueCount, 3);
        for (i = 0; i < trueCount; i++) {
          work = x1[i];
          G[i] = rt_powd_snf(work, 3.0);
          G[i + G.size(0)] = x1[i];
        }
        for (i = 0; i < ibmat; i++) {
          G[i + G.size(0) * 2] = 1.0;
        }
        idx = G.size(0);
        for (ibmat = 0; ibmat < 3; ibmat++) {
          ibtile = ibmat * 3;
          boffset = ibmat * G.size(0);
          b_C[ibtile] = 0.0;
          b_C[ibtile + 1] = 0.0;
          b_C[ibtile + 2] = 0.0;
          for (int k{0}; k < idx; k++) {
            work = G[boffset + k];
            b_C[ibtile] += G[k] * work;
            b_C[ibtile + 1] += G[G.size(0) + k] * work;
            b_C[ibtile + 2] += G[(G.size(0) << 1) + k] * work;
          }
        }
        c_G.set_size(3, G.size(0));
        ibtile = G.size(0);
        for (i = 0; i < ibtile; i++) {
          c_G[3 * i] = G[i];
          c_G[3 * i + 1] = G[i + G.size(0)];
          c_G[3 * i + 2] = G[i + G.size(0) * 2];
        }
        coder::mldivide(b_C, c_G, A);
        i = A.size(1);
        d_C[0] = 0.0;
        d_C[1] = 0.0;
        d_C[2] = 0.0;
        for (int k{0}; k < i; k++) {
          idx = k * 3;
          for (int b_i{0}; b_i < 3; b_i++) {
            boffset = 0;
            for (ibtile = 0; ibtile <= nx_tmp; ibtile++) {
              if (ifit_data[ibtile]) {
                c_tmp_data[boffset] = static_cast<short>(ibtile);
                boffset++;
              }
            }
            d_C[b_i] += A[idx + b_i] * Di[static_cast<int>(c_tmp_data[k])];
          }
        }
        b_z[ibin] = d_C[1];
      } else {
        b_bool = false;
        if (fittype.size(1) == 6) {
          idx = 0;
          do {
            exitg2 = 0;
            if (idx < 6) {
              if (fittype[idx] != cv3[idx]) {
                exitg2 = 1;
              } else {
                idx++;
              }
            } else {
              b_bool = true;
              exitg2 = 1;
            }
          } while (exitg2 == 0);
        }
        if (b_bool) {
          double c_C[4];
          //  Fit structure function to D(z,r) = Ar^(2/3) + N
          b_G.set_size(trueCount, 2);
          for (i = 0; i < trueCount; i++) {
            b_G[i] = x1[i];
          }
          for (i = 0; i < ibmat; i++) {
            b_G[i + b_G.size(0)] = 1.0;
          }
          idx = b_G.size(0);
          for (ibmat = 0; ibmat < 2; ibmat++) {
            ibtile = ibmat << 1;
            boffset = ibmat * b_G.size(0);
            c_C[ibtile] = 0.0;
            c_C[ibtile + 1] = 0.0;
            for (int k{0}; k < idx; k++) {
              work = b_G[boffset + k];
              c_C[ibtile] += b_G[k] * work;
              c_C[ibtile + 1] += b_G[b_G.size(0) + k] * work;
            }
          }
          d_G.set_size(2, b_G.size(0));
          ibtile = b_G.size(0);
          for (i = 0; i < ibtile; i++) {
            d_G[2 * i] = b_G[i];
            d_G[2 * i + 1] = b_G[i + b_G.size(0)];
          }
          coder::b_mldivide(c_C, d_G, b_A);
          i = b_A.size(1);
          C[0] = 0.0;
          C[1] = 0.0;
          for (int k{0}; k < i; k++) {
            idx = k << 1;
            for (int b_i{0}; b_i < 2; b_i++) {
              boffset = 0;
              for (ibtile = 0; ibtile <= nx_tmp; ibtile++) {
                if (ifit_data[ibtile]) {
                  d_tmp_data[boffset] = static_cast<short>(ibtile);
                  boffset++;
                }
              }
              C[b_i] += b_A[idx + b_i] * Di[static_cast<int>(d_tmp_data[k])];
            }
          }
          b_z[ibin] = C[0];
        } else {
          b_bool = false;
          if (fittype.size(1) == 3) {
            idx = 0;
            do {
              exitg2 = 0;
              if (idx < 3) {
                if (fittype[idx] != cv4[idx]) {
                  exitg2 = 1;
                } else {
                  idx++;
                }
              } else {
                b_bool = true;
                exitg2 = 1;
              }
            } while (exitg2 == 0);
          }
          if (b_bool) {
            double c_C[4];
            //  Don't presume a slope
            idx = trueCount - 1;
            trueCount = 0;
            for (int b_i{0}; b_i <= idx; b_i++) {
              if (x1[b_i] > 0.0) {
                trueCount++;
              }
            }
            boffset = 0;
            for (int b_i{0}; b_i <= idx; b_i++) {
              if (x1[b_i] > 0.0) {
                b_tmp_data[boffset] = static_cast<short>(b_i);
                boffset++;
              }
            }
            b_x1.set_size(trueCount);
            for (i = 0; i < trueCount; i++) {
              b_x1[i] = x1[static_cast<int>(b_tmp_data[i])];
            }
            x1.set_size(b_x1.size(0));
            ibtile = b_x1.size(0);
            for (i = 0; i < ibtile; i++) {
              x1[i] = b_x1[i];
            }
            i = x1.size(0);
            for (int k{0}; k < i; k++) {
              x1[k] = std::log10(x1[k]);
            }
            b_G.set_size(x1.size(0), 2);
            ibtile = x1.size(0);
            for (i = 0; i < ibtile; i++) {
              b_G[i] = x1[i];
              b_G[i + b_G.size(0)] = 1.0;
            }
            idx = b_G.size(0);
            for (ibmat = 0; ibmat < 2; ibmat++) {
              ibtile = ibmat << 1;
              boffset = ibmat * b_G.size(0);
              c_C[ibtile] = 0.0;
              c_C[ibtile + 1] = 0.0;
              for (int k{0}; k < idx; k++) {
                work = b_G[boffset + k];
                c_C[ibtile] += b_G[k] * work;
                c_C[ibtile + 1] += b_G[b_G.size(0) + k] * work;
              }
            }
            boffset = 0;
            for (int b_i{0}; b_i <= nx_tmp; b_i++) {
              if (ifit_data[b_i]) {
                e_tmp_data[boffset] = static_cast<short>(b_i);
                boffset++;
              }
            }
            x1.set_size(trueCount);
            d_G.set_size(2, b_G.size(0));
            for (int k{0}; k < trueCount; k++) {
              x1[k] =
                  std::log10(Di[static_cast<int>(e_tmp_data[b_tmp_data[k]])]);
              d_G[2 * k] = b_G[k];
              d_G[2 * k + 1] = b_G[k + b_G.size(0)];
            }
            coder::b_mldivide(c_C, d_G, b_A);
            i = b_A.size(1);
            C[1] = 0.0;
            for (int k{0}; k < i; k++) {
              C[1] += b_A[(k << 1) + 1] * x1[k];
            }
            b_z[ibin] = rt_powd_snf(10.0, C[1]);
          }
        }
      }
      eps[ibin] = rt_powd_snf(b_z[ibin] / 2.1, 1.5);
    } else {
      //  Must contain more than 3 points
    }
  }
  //  Remove unphysical values
  for (int b_i{0}; b_i < 128; b_i++) {
    if (b_z[b_i] < 0.0) {
      eps[b_i] = rtNaN;
    }
  }
}

// End of code generation (processSIGburst_onboard.cpp)
