//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// processSIGburst_onboard_lowmem.cpp
//
// Code generation for function 'processSIGburst_onboard_lowmem'
//

// Include files
#include "processSIGburst_onboard_lowmem.h"
#include "combineVectorElements.h"
#include "diff.h"
#include "eig.h"
#include "find.h"
#include "interp1.h"
#include "mean.h"
#include "mldivide.h"
#include "movmedian.h"
#include "mtimes.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include "std.h"
#include "coder_array.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Declarations
static void b_minus(coder::array<double, 2U> &in1,
                    const coder::array<double, 2U> &in2);

static void binary_expand_op(coder::array<double, 2U> &in1,
                             const coder::array<double, 2U> &in2);

static void binary_expand_op(coder::array<double, 2U> &in1,
                             const coder::array<double, 1U> &in2);

static void minus(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2);

static double rt_powd_snf(double u0, double u1);

static double rt_roundd_snf(double u);

// Function Definitions
static void b_minus(coder::array<double, 2U> &in1,
                    const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in2;
  int aux_0_1;
  int aux_1_1;
  int b_loop_ub;
  int loop_ub;
  int stride_0_0;
  int stride_0_1;
  int stride_1_0;
  int stride_1_1;
  if (in1.size(0) == 1) {
    loop_ub = in2.size(0);
  } else {
    loop_ub = in1.size(0);
  }
  if (in1.size(1) == 1) {
    b_loop_ub = in2.size(1);
  } else {
    b_loop_ub = in1.size(1);
  }
  b_in2.set_size(loop_ub, b_loop_ub);
  stride_0_0 = (in2.size(0) != 1);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_0 = (in1.size(0) != 1);
  stride_1_1 = (in1.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (int i = 0; i < b_loop_ub; i++) {
    for (int i1 = 0; i1 < loop_ub; i1++) {
      b_in2[i1 + b_in2.size(0) * i] =
          in2[i1 * stride_0_0 + in2.size(0) * aux_0_1] -
          in1[i1 * stride_1_0 + in1.size(0) * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(b_in2.size(0), b_in2.size(1));
  loop_ub = b_in2.size(1);
  for (int i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in2.size(0);
    for (int i1 = 0; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in2[i1 + b_in2.size(0) * i];
    }
  }
}

static void binary_expand_op(coder::array<double, 2U> &in1,
                             const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in1;
  int aux_0_1;
  int aux_1_1;
  int b_loop_ub;
  int loop_ub;
  int stride_0_0;
  int stride_0_1;
  int stride_1_0;
  int stride_1_1;
  if (in2.size(0) == 1) {
    loop_ub = in1.size(0);
  } else {
    loop_ub = in2.size(0);
  }
  if (in2.size(1) == 1) {
    b_loop_ub = in1.size(1);
  } else {
    b_loop_ub = in2.size(1);
  }
  b_in1.set_size(loop_ub, b_loop_ub);
  stride_0_0 = (in1.size(0) != 1);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_0 = (in2.size(0) != 1);
  stride_1_1 = (in2.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (int i = 0; i < b_loop_ub; i++) {
    for (int i1 = 0; i1 < loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] =
          (in1[i1 * stride_0_0 + in1.size(0) * aux_0_1] +
           in2[i1 * stride_1_0 + in2.size(0) * aux_1_1]) /
          2.0;
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(b_in1.size(0), b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (int i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int i1 = 0; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
}

static void binary_expand_op(coder::array<double, 2U> &in1,
                             const coder::array<double, 1U> &in2)
{
  coder::array<double, 2U> b_in1;
  int b_loop_ub;
  int in2_idx_0;
  int loop_ub;
  int stride_0_0;
  in2_idx_0 = in2.size(0);
  if (in2_idx_0 == 1) {
    loop_ub = in1.size(0);
  } else {
    loop_ub = in2_idx_0;
  }
  b_in1.set_size(loop_ub, in1.size(1));
  stride_0_0 = (in1.size(0) != 1);
  in2_idx_0 = (in2_idx_0 != 1);
  b_loop_ub = in1.size(1);
  for (int i = 0; i < b_loop_ub; i++) {
    for (int i1 = 0; i1 < loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] =
          in1[i1 * stride_0_0 + in1.size(0) * i] - in2[i1 * in2_idx_0];
    }
  }
  in1.set_size(b_in1.size(0), b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (int i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int i1 = 0; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
}

static void minus(coder::array<double, 2U> &in1,
                  const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in1;
  int aux_0_1;
  int aux_1_1;
  int b_loop_ub;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in2.size(1) == 1) {
    loop_ub = in1.size(1);
  } else {
    loop_ub = in2.size(1);
  }
  b_in1.set_size(in1.size(0), loop_ub);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_1 = (in2.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (int i = 0; i < loop_ub; i++) {
    b_loop_ub = in1.size(0);
    for (int i1 = 0; i1 < b_loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] =
          in1[i1 + in1.size(0) * aux_0_1] - in2[aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(b_in1.size(0), b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (int i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int i1 = 0; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
}

static double rt_powd_snf(double u0, double u1)
{
  double y;
  if (rtIsNaN(u0) || rtIsNaN(u1)) {
    y = rtNaN;
  } else {
    double d;
    double d1;
    d = std::abs(u0);
    d1 = std::abs(u1);
    if (rtIsInf(u1)) {
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

static double rt_roundd_snf(double u)
{
  double y;
  if (std::abs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = std::floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = std::ceil(u - 0.5);
    }
  } else {
    y = u;
  }
  return y;
}

void processSIGburst_onboard_lowmem(coder::array<double, 2U> &w, double cs,
                                    double dz, double bz, double neoflp,
                                    double rmin, double rmax, double nzfit,
                                    const coder::array<char, 2U> &avgtype,
                                    const coder::array<char, 2U> &fittype,
                                    coder::array<double, 2U> &eps)
{
  static const char cv1[7] = {'l', 'o', 'g', 'm', 'e', 'a', 'n'};
  static const char cv3[6] = {'l', 'i', 'n', 'e', 'a', 'r'};
  static const char cv2[5] = {'c', 'u', 'b', 'i', 'c'};
  static const char cv[4] = {'m', 'e', 'a', 'n'};
  static const char cv4[3] = {'l', 'o', 'g'};
  coder::array<creal_T, 2U> EOFs;
  coder::array<creal_T, 2U> alpha;
  coder::array<creal_T, 2U> c_wfilt;
  coder::array<creal_T, 2U> eofs;
  coder::array<creal_T, 1U> E;
  coder::array<double, 2U> A;
  coder::array<double, 2U> G;
  coder::array<double, 2U> R;
  coder::array<double, 2U> Z0;
  coder::array<double, 2U> b_A;
  coder::array<double, 2U> b_G;
  coder::array<double, 2U> b_wfilt;
  coder::array<double, 2U> c_G;
  coder::array<double, 2U> d_G;
  coder::array<double, 2U> dwpij;
  coder::array<double, 2U> wfilt;
  coder::array<double, 2U> wp;
  coder::array<double, 2U> y;
  coder::array<double, 2U> z;
  coder::array<double, 1U> b_w;
  coder::array<double, 1U> b_z;
  coder::array<double, 1U> igood;
  coder::array<int, 2U> r;
  coder::array<int, 2U> r1;
  coder::array<int, 1U> iidx;
  coder::array<int, 1U> r3;
  coder::array<int, 1U> r4;
  coder::array<int, 1U> r5;
  coder::array<int, 1U> r6;
  coder::array<int, 1U> r7;
  coder::array<bool, 2U> ispike;
  coder::array<bool, 2U> r2;
  coder::array<bool, 1U> ifit;
  double bkj;
  double wfilt_re_tmp;
  int boffset;
  int c_i;
  int end_tmp;
  int exitg1;
  int i;
  int k;
  int loop_ub;
  int loop_ub_tmp;
  int nbin;
  int nx;
  int trueCount;
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
  //  Don't interpolate through bad pings
  //   ---- bad pings are currently tossed before computing eps
  //  LOW MEMORY VERSION NOTES:
  //  Everytime I create a new version of w, its 4 MB. Should remove at end
  //  Vast majority is in structure function matrix nbin x nbin x nping
  //  N pings + N z-bins
  nbin = w.size(0);
  if (w.size(0) < 1) {
    z.set_size(1, 0);
  } else {
    z.set_size(1, w.size(0));
    loop_ub = w.size(0) - 1;
    for (i = 0; i <= loop_ub; i++) {
      z[i] = static_cast<double>(i) + 1.0;
    }
  }
  b_z.set_size(z.size(1));
  loop_ub = z.size(1);
  for (i = 0; i < loop_ub; i++) {
    b_z[i] = (bz + 0.2) + dz * z[i];
  }
  //  Despike
  //  Find Spikes (phase-shift threshold, Shcherbina 2018)
  //  m, pulse distance
  //  Hz, pulse carrier frequency (1 MHz for Sig 1000)
  if (rtIsNaN(cs)) {
    bkj = 0.0;
    nx = 0;
  } else {
    bkj = cs;
    nx = 1;
  }
  bkj /= static_cast<double>(nx);
  //  m/s
  //  1 m
  //  Identify Spikes
  coder::movmedian(w, rt_roundd_snf(1.0 / dz), wfilt);
  if ((w.size(0) == wfilt.size(0)) && (w.size(1) == wfilt.size(1))) {
    loop_ub = w.size(0) * w.size(1);
    wfilt.set_size(w.size(0), w.size(1));
    for (i = 0; i < loop_ub; i++) {
      wfilt[i] = w[i] - wfilt[i];
    }
  } else {
    b_minus(wfilt, w);
  }
  nx = wfilt.size(0) * wfilt.size(1);
  wp.set_size(wfilt.size(0), wfilt.size(1));
  for (k = 0; k < nx; k++) {
    wp[k] = std::abs(wfilt[k]);
  }
  ispike.set_size(wp.size(0), wp.size(1));
  bkj = bkj * bkj / (4.0E+6 * (bz + dz * static_cast<double>(w.size(0)))) / 2.0;
  loop_ub_tmp = wp.size(0) * wp.size(1);
  for (i = 0; i < loop_ub_tmp; i++) {
    ispike[i] = (wp[i] > bkj);
  }
  //  was medfilt1
  //  Fill with linear interpolation
  //  winterp = NaN(size(w));
  i = w.size(1);
  for (nx = 0; nx < i; nx++) {
    loop_ub = ispike.size(0);
    ifit.set_size(ispike.size(0));
    for (k = 0; k < loop_ub; k++) {
      ifit[k] = !ispike[k + ispike.size(0) * nx];
    }
    coder::eml_find(ifit, iidx);
    igood.set_size(iidx.size(0));
    loop_ub = iidx.size(0);
    for (k = 0; k < loop_ub; k++) {
      igood[k] = iidx[k];
    }
    if (igood.size(0) > 3) {
      if (nbin < 1) {
        y.set_size(1, 0);
      } else {
        y.set_size(1, nbin);
        loop_ub = nbin - 1;
        for (k = 0; k <= loop_ub; k++) {
          y[k] = static_cast<double>(k) + 1.0;
        }
      }
      b_w.set_size(igood.size(0));
      loop_ub = igood.size(0);
      for (k = 0; k < loop_ub; k++) {
        b_w[k] = w[(static_cast<int>(igood[k]) + w.size(0) * nx) - 1];
      }
      coder::interp1(igood, b_w, y, dwpij);
      loop_ub = w.size(0);
      for (k = 0; k < loop_ub; k++) {
        w[k + w.size(0) * nx] = dwpij[k];
      }
    }
  }
  //  Peform EOF High-pass
  //  Identify badpings with greater than 50% spikes
  //
  //  Compute EOFs from good pings
  coder::combineVectorElements(ispike, r);
  nx = r.size(1) - 1;
  trueCount = 0;
  for (int b_i = 0; b_i <= nx; b_i++) {
    if (!(static_cast<double>(r[b_i]) / static_cast<double>(w.size(0)) > 0.5)) {
      trueCount++;
    }
  }
  r1.set_size(1, trueCount);
  boffset = 0;
  for (int b_i = 0; b_i <= nx; b_i++) {
    if (!(static_cast<double>(r[b_i]) / static_cast<double>(w.size(0)) > 0.5)) {
      r1[boffset] = b_i;
      boffset++;
    }
  }
  wfilt.set_size(r1.size(1), w.size(0));
  loop_ub = w.size(0);
  for (i = 0; i < loop_ub; i++) {
    boffset = r1.size(1);
    for (k = 0; k < boffset; k++) {
      wfilt[k + wfilt.size(0) * i] = w[i + w.size(0) * r1[k]];
    }
  }
  coder::mean(wfilt, dwpij);
  if (wfilt.size(1) == dwpij.size(1)) {
    b_wfilt.set_size(wfilt.size(0), wfilt.size(1));
    loop_ub = wfilt.size(1);
    for (i = 0; i < loop_ub; i++) {
      boffset = wfilt.size(0);
      for (k = 0; k < boffset; k++) {
        b_wfilt[k + b_wfilt.size(0) * i] =
            wfilt[k + wfilt.size(0) * i] - dwpij[i];
      }
    }
    wfilt.set_size(b_wfilt.size(0), b_wfilt.size(1));
    loop_ub = b_wfilt.size(0) * b_wfilt.size(1);
    for (i = 0; i < loop_ub; i++) {
      wfilt[i] = b_wfilt[i];
    }
  } else {
    minus(wfilt, dwpij);
  }
  end_tmp = wfilt.size(0) * wfilt.size(1);
  nx = end_tmp - 1;
  for (int b_i = 0; b_i <= nx; b_i++) {
    if (rtIsNaN(wfilt[b_i])) {
      wfilt[b_i] = 0.0;
    }
  }
  coder::internal::blas::mtimes(wfilt, wfilt, wp);
  coder::eig(wp, EOFs, E);
  coder::internal::sort(E, iidx);
  eofs.set_size(EOFs.size(0), iidx.size(0));
  loop_ub = iidx.size(0);
  for (i = 0; i < loop_ub; i++) {
    boffset = EOFs.size(0);
    for (k = 0; k < boffset; k++) {
      eofs[k + eofs.size(0) * i] = EOFs[k + EOFs.size(0) * (iidx[i] - 1)];
    }
  }
  c_wfilt.set_size(wfilt.size(0), wfilt.size(1));
  for (i = 0; i < end_tmp; i++) {
    c_wfilt[i].re = wfilt[i];
    c_wfilt[i].im = 0.0;
  }
  alpha.set_size(c_wfilt.size(0), eofs.size(1));
  loop_ub = c_wfilt.size(0);
  for (i = 0; i < loop_ub; i++) {
    boffset = eofs.size(1);
    for (k = 0; k < boffset; k++) {
      alpha[i + alpha.size(0) * k].re = 0.0;
      alpha[i + alpha.size(0) * k].im = 0.0;
      nx = c_wfilt.size(1);
      for (c_i = 0; c_i < nx; c_i++) {
        double b_wfilt_re_tmp;
        double c_wfilt_re_tmp;
        bkj = c_wfilt[i + c_wfilt.size(0) * c_i].re;
        wfilt_re_tmp = eofs[c_i + eofs.size(0) * k].im;
        b_wfilt_re_tmp = c_wfilt[i + c_wfilt.size(0) * c_i].im;
        c_wfilt_re_tmp = eofs[c_i + eofs.size(0) * k].re;
        alpha[i + alpha.size(0) * k].re =
            alpha[i + alpha.size(0) * k].re +
            (bkj * c_wfilt_re_tmp - b_wfilt_re_tmp * wfilt_re_tmp);
        alpha[i + alpha.size(0) * k].im =
            alpha[i + alpha.size(0) * k].im +
            (bkj * wfilt_re_tmp + b_wfilt_re_tmp * c_wfilt_re_tmp);
      }
    }
  }
  //  Reconstruct w/high-mode EOFs
  wp.set_size(w.size(0), w.size(1));
  end_tmp = w.size(0) * w.size(1);
  for (i = 0; i < end_tmp; i++) {
    wp[i] = rtNaN;
  }
  if (neoflp + 1.0 > iidx.size(0)) {
    i = 0;
    k = 0;
  } else {
    i = static_cast<int>(neoflp + 1.0) - 1;
    k = iidx.size(0);
  }
  if (neoflp + 1.0 > alpha.size(1)) {
    c_i = 0;
    trueCount = 0;
  } else {
    c_i = static_cast<int>(neoflp + 1.0) - 1;
    trueCount = alpha.size(1);
  }
  iidx.set_size(r1.size(1));
  loop_ub = r1.size(1);
  for (boffset = 0; boffset < loop_ub; boffset++) {
    iidx[boffset] = r1[boffset];
  }
  nx = EOFs.size(0);
  loop_ub = k - i;
  for (k = 0; k < loop_ub; k++) {
    for (boffset = 0; boffset < nx; boffset++) {
      eofs[boffset + nx * k] = eofs[boffset + eofs.size(0) * (i + k)];
    }
  }
  eofs.set_size(EOFs.size(0), loop_ub);
  boffset = alpha.size(0);
  loop_ub = trueCount - c_i;
  for (i = 0; i < loop_ub; i++) {
    for (k = 0; k < boffset; k++) {
      alpha[k + boffset * i] = alpha[k + alpha.size(0) * (c_i + i)];
    }
  }
  alpha.set_size(alpha.size(0), loop_ub);
  coder::internal::blas::mtimes(eofs, alpha, EOFs);
  loop_ub = EOFs.size(1);
  for (i = 0; i < loop_ub; i++) {
    boffset = EOFs.size(0);
    for (k = 0; k < boffset; k++) {
      wp[k + wp.size(0) * iidx[i]] = EOFs[k + EOFs.size(0) * i].re;
    }
  }
  //  Remove spikes
  nx = loop_ub_tmp - 1;
  for (int b_i = 0; b_i <= nx; b_i++) {
    if (ispike[b_i]) {
      wp[b_i] = rtNaN;
    }
  }
  //  Compute Structure Function
  //  Matrices of all possible data pair separation distances (R) and
  //    corresponding mean vertical position (Z0)
  z.set_size(1, z.size(1));
  loop_ub_tmp = z.size(1) - 1;
  for (i = 0; i <= loop_ub_tmp; i++) {
    z[i] = (bz + 0.2) + dz * z[i];
  }
  y.set_size(1, b_z.size(0));
  loop_ub = b_z.size(0);
  for (i = 0; i < loop_ub; i++) {
    y[i] = b_z[i];
  }
  coder::diff(y, dwpij);
  dz = coder::mean(dwpij);
  //  R = round(R,2);
  R.set_size(z.size(1), z.size(1));
  loop_ub = z.size(1);
  for (i = 0; i < loop_ub; i++) {
    boffset = z.size(1);
    for (k = 0; k < boffset; k++) {
      R[k + R.size(0) * i] = (z[i] - z[k]) * 100.0;
    }
  }
  nx = R.size(0) * R.size(1);
  for (k = 0; k < nx; k++) {
    R[k] = rt_roundd_snf(R[k]);
  }
  for (i = 0; i < nx; i++) {
    R[i] = R[i] / 100.0;
  }
  Z0.set_size(b_z.size(0), b_z.size(0));
  wfilt.set_size(b_z.size(0), b_z.size(0));
  if (b_z.size(0) != 0) {
    for (trueCount = 0; trueCount <= loop_ub_tmp; trueCount++) {
      for (int b_i = 0; b_i <= loop_ub_tmp; b_i++) {
        Z0[b_i + Z0.size(0) * trueCount] = b_z[trueCount];
        wfilt[b_i + wfilt.size(0) * trueCount] = b_z[b_i];
      }
    }
  }
  if ((Z0.size(0) == wfilt.size(0)) && (Z0.size(1) == wfilt.size(1))) {
    for (i = 0; i < nx; i++) {
      Z0[i] = (Z0[i] + wfilt[i]) / 2.0;
    }
  } else {
    binary_expand_op(Z0, wfilt);
  }
  //  Remove time-mean from turbulent velocities
  coder::mean(wp, igood);
  if (wp.size(0) == igood.size(0)) {
    b_wfilt.set_size(wp.size(0), wp.size(1));
    loop_ub = wp.size(1);
    for (i = 0; i < loop_ub; i++) {
      boffset = wp.size(0);
      for (k = 0; k < boffset; k++) {
        b_wfilt[k + b_wfilt.size(0) * i] = wp[k + wp.size(0) * i] - igood[k];
      }
    }
    wp.set_size(b_wfilt.size(0), b_wfilt.size(1));
    for (i = 0; i < end_tmp; i++) {
      wp[i] = b_wfilt[i];
    }
  } else {
    binary_expand_op(wp, igood);
  }
  //  Mean squared velocity bin-pair squared differences
  wfilt.set_size(w.size(0), w.size(0));
  loop_ub = w.size(0) * w.size(0);
  for (i = 0; i < loop_ub; i++) {
    wfilt[i] = rtNaN;
  }
  i = w.size(0);
  for (int b_i = 0; b_i < i; b_i++) {
    for (trueCount = 0; trueCount < nbin; trueCount++) {
      loop_ub = wp.size(1);
      dwpij.set_size(1, wp.size(1));
      for (k = 0; k < loop_ub; k++) {
        dwpij[k] = wp[b_i + wp.size(0) * k] - wp[trueCount + wp.size(0) * k];
      }
      nx = dwpij.size(1);
      y.set_size(1, dwpij.size(1));
      for (k = 0; k < nx; k++) {
        y[k] = std::abs(dwpij[k]);
      }
      r2.set_size(1, y.size(1));
      bkj = 5.0 * coder::b_std(dwpij);
      loop_ub = y.size(1);
      for (k = 0; k < loop_ub; k++) {
        r2[k] = (y[k] > bkj);
      }
      nx = r2.size(1) - 1;
      for (c_i = 0; c_i <= nx; c_i++) {
        if (r2[c_i]) {
          dwpij[c_i] = rtNaN;
        }
      }
      //  remove > 5*sigma
      b_bool = false;
      if (avgtype.size(1) == 4) {
        nx = 0;
        do {
          exitg1 = 0;
          if (nx < 4) {
            if (avgtype[nx] != cv[nx]) {
              exitg1 = 1;
            } else {
              nx++;
            }
          } else {
            b_bool = true;
            exitg1 = 1;
          }
        } while (exitg1 == 0);
      }
      if (b_bool) {
        y.set_size(1, dwpij.size(1));
        loop_ub = dwpij.size(1);
        for (k = 0; k < loop_ub; k++) {
          bkj = dwpij[k];
          y[k] = bkj * bkj;
        }
        wfilt[b_i + wfilt.size(0) * trueCount] = coder::b_mean(y);
      } else {
        b_bool = false;
        if (avgtype.size(1) == 7) {
          nx = 0;
          do {
            exitg1 = 0;
            if (nx < 7) {
              if (avgtype[nx] != cv1[nx]) {
                exitg1 = 1;
              } else {
                nx++;
              }
            } else {
              b_bool = true;
              exitg1 = 1;
            }
          } while (exitg1 == 0);
        }
        if (b_bool) {
          y.set_size(1, dwpij.size(1));
          loop_ub = dwpij.size(1);
          for (k = 0; k < loop_ub; k++) {
            bkj = dwpij[k];
            y[k] = bkj * bkj;
          }
          nx = y.size(1);
          for (k = 0; k < nx; k++) {
            y[k] = std::log10(y[k]);
          }
          wfilt[b_i + wfilt.size(0) * trueCount] =
              rt_powd_snf(10.0, coder::b_mean(y));
        }
      }
    }
  }
  //  Calculate Dissipation Rate
  //  Fit structure function to theoretical curve
  eps.set_size(1, b_z.size(0));
  loop_ub = b_z.size(0);
  for (i = 0; i < loop_ub; i++) {
    eps[i] = rtNaN;
  }
  dwpij.set_size(1, b_z.size(0));
  loop_ub = b_z.size(0);
  for (i = 0; i < loop_ub; i++) {
    dwpij[i] = rtNaN;
  }
  i = z.size(1);
  for (nbin = 0; nbin < i; nbin++) {
    //  Find points in z0 bin
    nx = Z0.size(0) * Z0.size(1) - 1;
    trueCount = 0;
    for (int b_i = 0; b_i <= nx; b_i++) {
      bkj = z[nbin];
      wfilt_re_tmp = 1.1 * nzfit * dz / 2.0;
      if ((Z0[b_i] >= bkj - wfilt_re_tmp) && (Z0[b_i] <= bkj + wfilt_re_tmp)) {
        trueCount++;
      }
    }
    r3.set_size(trueCount);
    boffset = 0;
    for (int b_i = 0; b_i <= nx; b_i++) {
      bkj = z[nbin];
      wfilt_re_tmp = 1.1 * nzfit * dz / 2.0;
      if ((Z0[b_i] >= bkj - wfilt_re_tmp) && (Z0[b_i] <= bkj + wfilt_re_tmp)) {
        r3[boffset] = b_i;
        boffset++;
      }
    }
    loop_ub = r3.size(0);
    igood.set_size(r3.size(0));
    for (k = 0; k < loop_ub; k++) {
      igood[k] = R[r3[k]];
    }
    coder::internal::sort(igood, iidx);
    b_z.set_size(iidx.size(0));
    loop_ub = iidx.size(0);
    for (k = 0; k < loop_ub; k++) {
      b_z[k] = wfilt[r3[iidx[k] - 1]];
    }
    //  Select points within specified separation scale range
    ifit.set_size(igood.size(0));
    loop_ub = igood.size(0);
    for (k = 0; k < loop_ub; k++) {
      ifit[k] = ((igood[k] <= rmax) && (igood[k] >= rmin));
    }
    nx = igood.size(0);
    if (igood.size(0) == 0) {
      loop_ub = 0;
    } else {
      loop_ub = ((igood[0] <= rmax) && (igood[0] >= rmin));
      for (k = 2; k <= nx; k++) {
        bkj = igood[k - 1];
        loop_ub += ((bkj <= rmax) && (bkj >= rmin));
      }
    }
    nx = igood.size(0);
    if (igood.size(0) == 0) {
      boffset = 0;
    } else {
      boffset = ((igood[0] <= rmax) && (igood[0] >= rmin));
      for (k = 2; k <= nx; k++) {
        bkj = igood[k - 1];
        boffset += ((bkj <= rmax) && (bkj >= rmin));
      }
    }
    if (boffset >= 3) {
      end_tmp = igood.size(0) - 1;
      trueCount = 0;
      for (int b_i = 0; b_i <= end_tmp; b_i++) {
        if ((igood[b_i] <= rmax) && (igood[b_i] >= rmin)) {
          trueCount++;
        }
      }
      boffset = 0;
      for (int b_i = 0; b_i <= end_tmp; b_i++) {
        if ((igood[b_i] <= rmax) && (igood[b_i] >= rmin)) {
          bkj = igood[b_i];
          igood[boffset] = rt_powd_snf(bkj, 0.66666666666666663);
          boffset++;
        }
      }
      igood.set_size(trueCount);
      // Fit Structure function to theoretical curves
      b_bool = false;
      if (fittype.size(1) == 5) {
        nx = 0;
        do {
          exitg1 = 0;
          if (nx < 5) {
            if (fittype[nx] != cv2[nx]) {
              exitg1 = 1;
            } else {
              nx++;
            }
          } else {
            b_bool = true;
            exitg1 = 1;
          }
        } while (exitg1 == 0);
      }
      if (b_bool) {
        double b_C[9];
        double c_C[3];
        //  Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
        G.set_size(trueCount, 3);
        for (k = 0; k < trueCount; k++) {
          bkj = igood[k];
          G[k] = rt_powd_snf(bkj, 3.0);
          G[k + G.size(0)] = igood[k];
        }
        for (k = 0; k < loop_ub; k++) {
          G[k + G.size(0) * 2] = 1.0;
        }
        loop_ub = G.size(0);
        for (trueCount = 0; trueCount < 3; trueCount++) {
          nx = trueCount * 3;
          boffset = trueCount * G.size(0);
          b_C[nx] = 0.0;
          b_C[nx + 1] = 0.0;
          b_C[nx + 2] = 0.0;
          for (k = 0; k < loop_ub; k++) {
            bkj = G[boffset + k];
            b_C[nx] += G[k] * bkj;
            b_C[nx + 1] += G[G.size(0) + k] * bkj;
            b_C[nx + 2] += G[(G.size(0) << 1) + k] * bkj;
          }
        }
        d_G.set_size(3, G.size(0));
        loop_ub = G.size(0);
        for (k = 0; k < loop_ub; k++) {
          d_G[3 * k] = G[k];
          d_G[3 * k + 1] = G[k + G.size(0)];
          d_G[3 * k + 2] = G[k + G.size(0) * 2];
        }
        coder::mldivide(b_C, d_G, A);
        loop_ub = A.size(1);
        c_C[0] = 0.0;
        c_C[1] = 0.0;
        c_C[2] = 0.0;
        for (k = 0; k < loop_ub; k++) {
          nx = k * 3;
          for (int b_i = 0; b_i < 3; b_i++) {
            trueCount = 0;
            for (c_i = 0; c_i <= end_tmp; c_i++) {
              if (ifit[c_i]) {
                trueCount++;
              }
            }
            r5.set_size(trueCount);
            boffset = 0;
            for (c_i = 0; c_i <= end_tmp; c_i++) {
              if (ifit[c_i]) {
                r5[boffset] = c_i;
                boffset++;
              }
            }
            c_C[b_i] += A[nx + b_i] * b_z[r5[k]];
          }
        }
        dwpij[nbin] = c_C[1];
      } else {
        b_bool = false;
        if (fittype.size(1) == 6) {
          nx = 0;
          do {
            exitg1 = 0;
            if (nx < 6) {
              if (fittype[nx] != cv3[nx]) {
                exitg1 = 1;
              } else {
                nx++;
              }
            } else {
              b_bool = true;
              exitg1 = 1;
            }
          } while (exitg1 == 0);
        }
        if (b_bool) {
          double C[2];
          //  Fit structure function to D(z,r) = Ar^(2/3) + N
          b_G.set_size(trueCount, 2);
          for (k = 0; k < trueCount; k++) {
            b_G[k] = igood[k];
          }
          for (k = 0; k < loop_ub; k++) {
            b_G[k + b_G.size(0)] = 1.0;
          }
          c_G.set_size(2, b_G.size(0));
          loop_ub = b_G.size(0);
          for (k = 0; k < loop_ub; k++) {
            c_G[2 * k] = b_G[k];
            c_G[2 * k + 1] = b_G[k + b_G.size(0)];
          }
          double dv[4];
          coder::internal::blas::mtimes(b_G, b_G, dv);
          coder::b_mldivide(dv, c_G, b_A);
          loop_ub = b_A.size(1);
          C[0] = 0.0;
          C[1] = 0.0;
          for (k = 0; k < loop_ub; k++) {
            nx = k << 1;
            for (int b_i = 0; b_i < 2; b_i++) {
              trueCount = 0;
              for (c_i = 0; c_i <= end_tmp; c_i++) {
                if (ifit[c_i]) {
                  trueCount++;
                }
              }
              r6.set_size(trueCount);
              boffset = 0;
              for (c_i = 0; c_i <= end_tmp; c_i++) {
                if (ifit[c_i]) {
                  r6[boffset] = c_i;
                  boffset++;
                }
              }
              C[b_i] += b_A[nx + b_i] * b_z[r6[k]];
            }
          }
          dwpij[nbin] = C[0];
        } else {
          b_bool = false;
          if (fittype.size(1) == 3) {
            nx = 0;
            do {
              exitg1 = 0;
              if (nx < 3) {
                if (fittype[nx] != cv4[nx]) {
                  exitg1 = 1;
                } else {
                  nx++;
                }
              } else {
                b_bool = true;
                exitg1 = 1;
              }
            } while (exitg1 == 0);
          }
          if (b_bool) {
            double C[2];
            //  Don't presume a slope
            nx = trueCount - 1;
            trueCount = 0;
            for (int b_i = 0; b_i <= nx; b_i++) {
              if (igood[b_i] > 0.0) {
                trueCount++;
              }
            }
            r4.set_size(trueCount);
            boffset = 0;
            for (int b_i = 0; b_i <= nx; b_i++) {
              if (igood[b_i] > 0.0) {
                r4[boffset] = b_i;
                boffset++;
              }
            }
            loop_ub = r4.size(0);
            b_w.set_size(r4.size(0));
            for (k = 0; k < loop_ub; k++) {
              b_w[k] = igood[r4[k]];
            }
            igood.set_size(b_w.size(0));
            loop_ub = b_w.size(0);
            for (k = 0; k < loop_ub; k++) {
              igood[k] = b_w[k];
            }
            nx = igood.size(0);
            for (k = 0; k < nx; k++) {
              igood[k] = std::log10(igood[k]);
            }
            b_G.set_size(igood.size(0), 2);
            loop_ub = igood.size(0);
            for (k = 0; k < loop_ub; k++) {
              b_G[k] = igood[k];
              b_G[k + b_G.size(0)] = 1.0;
            }
            trueCount = 0;
            for (int b_i = 0; b_i <= end_tmp; b_i++) {
              if (ifit[b_i]) {
                trueCount++;
              }
            }
            r7.set_size(trueCount);
            boffset = 0;
            for (int b_i = 0; b_i <= end_tmp; b_i++) {
              if (ifit[b_i]) {
                r7[boffset] = b_i;
                boffset++;
              }
            }
            loop_ub = r4.size(0);
            igood.set_size(r4.size(0));
            c_G.set_size(2, b_G.size(0));
            for (k = 0; k < loop_ub; k++) {
              igood[k] = std::log10(b_z[r7[r4[k]]]);
              c_G[2 * k] = b_G[k];
              c_G[2 * k + 1] = b_G[k + b_G.size(0)];
            }
            double dv[4];
            coder::internal::blas::mtimes(b_G, b_G, dv);
            coder::b_mldivide(dv, c_G, b_A);
            loop_ub = b_A.size(1);
            C[1] = 0.0;
            for (k = 0; k < loop_ub; k++) {
              C[1] += b_A[(k << 1) + 1] * igood[k];
            }
            dwpij[nbin] = rt_powd_snf(10.0, C[1]);
          }
        }
      }
      eps[nbin] = rt_powd_snf(dwpij[nbin] / 2.1, 1.5);
    } else {
      //  Must contain more than 3 points
    }
  }
  //  Remove unphysical values
  for (int b_i = 0; b_i <= loop_ub_tmp; b_i++) {
    if (dwpij[b_i] < 0.0) {
      eps[b_i] = rtNaN;
    }
  }
}

// End of code generation (processSIGburst_onboard_lowmem.cpp)
