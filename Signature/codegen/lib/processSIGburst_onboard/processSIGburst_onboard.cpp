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
#include "abs.h"
#include "combineVectorElements.h"
#include "diff.h"
#include "eig.h"
#include "find.h"
#include "interp1.h"
#include "mean.h"
#include "mldivide.h"
#include "movmedian.h"
#include "mtimes.h"
#include "permute.h"
#include "processSIGburst_onboard_data.h"
#include "processSIGburst_onboard_initialize.h"
#include "repmat.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include "std.h"
#include "strcmp.h"
#include "coder_array.h"
#include <cmath>

// Function Declarations
static void b_binary_expand_op(coder::array<double, 2U> &in1,
                               const coder::array<double, 2U> &in2,
                               const coder::array<double, 2U> &in3);

static void b_binary_expand_op(coder::array<double, 2U> &in1,
                               const coder::array<double, 2U> &in2);

static void b_binary_expand_op(coder::array<double, 3U> &in1,
                               const coder::array<double, 2U> &in2,
                               const coder::array<double, 1U> &in3,
                               const coder::array<double, 2U> &in4);

static void binary_expand_op(coder::array<bool, 3U> &in1,
                             const coder::array<double, 3U> &in2,
                             const coder::array<double, 2U> &in3);

static void c_binary_expand_op(coder::array<double, 2U> &in1,
                               const coder::array<double, 2U> &in2);

static void minus(coder::array<double, 3U> &in1,
                  const coder::array<double, 3U> &in2,
                  const coder::array<double, 3U> &in3);

static double rt_powd_snf(double u0, double u1);

// Function Definitions
static void b_binary_expand_op(coder::array<double, 2U> &in1,
                               const coder::array<double, 2U> &in2,
                               const coder::array<double, 2U> &in3)
{
  coder::array<double, 2U> b_in1;
  int aux_0_1;
  int aux_1_1;
  int aux_2_1;
  int b_loop_ub;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  int stride_2_1;
  if (in3.size(1) == 1) {
    i = in2.size(1);
  } else {
    i = in3.size(1);
  }
  if (i == 1) {
    loop_ub = in1.size(1);
  } else {
    loop_ub = i;
  }
  b_in1.set_size(in1.size(0), loop_ub);
  stride_0_1 = (in1.size(1) != 1);
  stride_1_1 = (in2.size(1) != 1);
  stride_2_1 = (in3.size(1) != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  aux_2_1 = 0;
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = in1.size(0);
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] =
          in1[i1 + in1.size(0) * aux_0_1] - in2[aux_1_1] / in3[aux_2_1];
    }
    aux_2_1 += stride_2_1;
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  in1.set_size(b_in1.size(0), b_in1.size(1));
  loop_ub = b_in1.size(1);
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
}

static void b_binary_expand_op(coder::array<double, 2U> &in1,
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
  for (int i{0}; i < b_loop_ub; i++) {
    for (int i1{0}; i1 < loop_ub; i1++) {
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
  for (int i{0}; i < loop_ub; i++) {
    b_loop_ub = b_in1.size(0);
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
}

static void b_binary_expand_op(coder::array<double, 3U> &in1,
                               const coder::array<double, 2U> &in2,
                               const coder::array<double, 1U> &in3,
                               const coder::array<double, 2U> &in4)
{
  coder::array<double, 2U> b_in2;
  int b_loop_ub;
  int in3_idx_0;
  int loop_ub;
  int stride_0_0;
  in3_idx_0 = in3.size(0);
  if (in3_idx_0 == 1) {
    loop_ub = in2.size(0);
  } else {
    loop_ub = in3_idx_0;
  }
  b_in2.set_size(loop_ub, in2.size(1));
  stride_0_0 = (in2.size(0) != 1);
  in3_idx_0 = (in3_idx_0 != 1);
  b_loop_ub = in2.size(1);
  for (int i{0}; i < b_loop_ub; i++) {
    for (int i1{0}; i1 < loop_ub; i1++) {
      b_in2[i1 + b_in2.size(0) * i] =
          in2[i1 * stride_0_0 + in2.size(0) * i] - in3[i1 * in3_idx_0];
    }
  }
  coder::repmat(b_in2, static_cast<double>(in4.size(0)), in1);
}

static void binary_expand_op(coder::array<bool, 3U> &in1,
                             const coder::array<double, 3U> &in2,
                             const coder::array<double, 2U> &in3)
{
  int b_loop_ub;
  int c_loop_ub;
  int in3_idx_0;
  int in3_idx_1;
  int loop_ub;
  int stride_0_0;
  int stride_0_1;
  int stride_1_0;
  in3_idx_0 = in3.size(0);
  in3_idx_1 = in3.size(1);
  if (in3_idx_0 == 1) {
    loop_ub = in2.size(0);
  } else {
    loop_ub = in3_idx_0;
  }
  in1.set_size(loop_ub, in1.size(1), in1.size(2));
  if (in3_idx_1 == 1) {
    b_loop_ub = in2.size(1);
  } else {
    b_loop_ub = in3_idx_1;
  }
  in1.set_size(in1.size(0), b_loop_ub, in2.size(2));
  stride_0_0 = (in2.size(0) != 1);
  stride_0_1 = (in2.size(1) != 1);
  stride_1_0 = (in3_idx_0 != 1);
  in3_idx_1 = (in3_idx_1 != 1);
  c_loop_ub = in2.size(2);
  for (int i{0}; i < c_loop_ub; i++) {
    int aux_0_1;
    int aux_1_1;
    aux_0_1 = 0;
    aux_1_1 = 0;
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      for (int i2{0}; i2 < loop_ub; i2++) {
        in1[(i2 + in1.size(0) * i1) + in1.size(0) * in1.size(1) * i] =
            (in2[(i2 * stride_0_0 + in2.size(0) * aux_0_1) +
                 in2.size(0) * in2.size(1) * i] >
             in3[i2 * stride_1_0 + in3_idx_0 * aux_1_1]);
      }
      aux_1_1 += in3_idx_1;
      aux_0_1 += stride_0_1;
    }
  }
}

static void c_binary_expand_op(coder::array<double, 2U> &in1,
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
  for (int i{0}; i < b_loop_ub; i++) {
    for (int i1{0}; i1 < loop_ub; i1++) {
      b_in2[i1 + b_in2.size(0) * i] =
          in2[i1 * stride_0_0 + in2.size(0) * aux_0_1] -
          in1[i1 * stride_1_0 + in1.size(0) * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  coder::b_abs(b_in2, in1);
}

static void minus(coder::array<double, 3U> &in1,
                  const coder::array<double, 3U> &in2,
                  const coder::array<double, 3U> &in3)
{
  int aux_0_2;
  int aux_1_2;
  int b_loop_ub;
  int c_loop_ub;
  int loop_ub;
  int stride_0_0;
  int stride_0_1;
  int stride_0_2;
  int stride_1_0;
  int stride_1_1;
  int stride_1_2;
  if (in3.size(0) == 1) {
    loop_ub = in2.size(0);
  } else {
    loop_ub = in3.size(0);
  }
  in1.set_size(loop_ub, in1.size(1), in1.size(2));
  if (in3.size(1) == 1) {
    b_loop_ub = in2.size(1);
  } else {
    b_loop_ub = in3.size(1);
  }
  in1.set_size(in1.size(0), b_loop_ub, in1.size(2));
  if (in3.size(2) == 1) {
    c_loop_ub = in2.size(2);
  } else {
    c_loop_ub = in3.size(2);
  }
  in1.set_size(in1.size(0), in1.size(1), c_loop_ub);
  stride_0_0 = (in2.size(0) != 1);
  stride_0_1 = (in2.size(1) != 1);
  stride_0_2 = (in2.size(2) != 1);
  stride_1_0 = (in3.size(0) != 1);
  stride_1_1 = (in3.size(1) != 1);
  stride_1_2 = (in3.size(2) != 1);
  aux_0_2 = 0;
  aux_1_2 = 0;
  for (int i{0}; i < c_loop_ub; i++) {
    int aux_0_1;
    int aux_1_1;
    aux_0_1 = 0;
    aux_1_1 = 0;
    for (int i1{0}; i1 < b_loop_ub; i1++) {
      for (int i2{0}; i2 < loop_ub; i2++) {
        in1[(i2 + in1.size(0) * i1) + in1.size(0) * in1.size(1) * i] =
            in2[(i2 * stride_0_0 + in2.size(0) * aux_0_1) +
                in2.size(0) * in2.size(1) * aux_0_2] -
            in3[(i2 * stride_1_0 + in3.size(0) * aux_1_1) +
                in3.size(0) * in3.size(1) * aux_1_2];
      }
      aux_1_1 += stride_1_1;
      aux_0_1 += stride_0_1;
    }
    aux_1_2 += stride_1_2;
    aux_0_2 += stride_0_2;
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
                             coder::array<double, 2U> &eps)
{
  static const char cv1[6]{'l', 'i', 'n', 'e', 'a', 'r'};
  static const char cv[5]{'c', 'u', 'b', 'i', 'c'};
  static const char cv2[3]{'l', 'o', 'g'};
  coder::array<creal_T, 2U> EOFs;
  coder::array<creal_T, 2U> alpha;
  coder::array<creal_T, 2U> b_X;
  coder::array<creal_T, 2U> eofs;
  coder::array<creal_T, 1U> E;
  coder::array<double, 3U> dW;
  coder::array<double, 3U> r2;
  coder::array<double, 3U> r3;
  coder::array<double, 2U> A;
  coder::array<double, 2U> D;
  coder::array<double, 2U> G;
  coder::array<double, 2U> X;
  coder::array<double, 2U> Z0;
  coder::array<double, 2U> b_A;
  coder::array<double, 2U> b_G;
  coder::array<double, 2U> b_wfilt;
  coder::array<double, 2U> c_G;
  coder::array<double, 2U> d_G;
  coder::array<double, 2U> n;
  coder::array<double, 2U> wfilt;
  coder::array<double, 2U> winterp;
  coder::array<double, 2U> x;
  coder::array<double, 2U> z;
  coder::array<double, 1U> b_wraw;
  coder::array<double, 1U> b_z;
  coder::array<double, 1U> igood;
  coder::array<int, 2U> r;
  coder::array<int, 2U> r1;
  coder::array<int, 1U> iidx;
  coder::array<int, 1U> r5;
  coder::array<int, 1U> r6;
  coder::array<int, 1U> r7;
  coder::array<int, 1U> r8;
  coder::array<int, 1U> r9;
  coder::array<bool, 3U> r4;
  coder::array<bool, 2U> b_nans;
  coder::array<bool, 2U> c_nans;
  coder::array<bool, 2U> ispike;
  coder::array<bool, 1U> ifit;
  double bsum;
  double unnamed_idx_0;
  int b_loop_ub_tmp;
  int hi;
  int i;
  int ib;
  int lastBlockLength;
  int loop_ub_tmp;
  int nblocks;
  int npages;
  int nx;
  int xblockoffset;
  int xpageoffset;
  bool nans;
  if (!isInitialized_processSIGburst_onboard) {
    processSIGburst_onboard_initialize();
  }
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
  //  N pings + N z-bins
  npages = wraw.size(0);
  if (wraw.size(0) < 1) {
    z.set_size(1, 0);
  } else {
    z.set_size(1, wraw.size(0));
    hi = wraw.size(0) - 1;
    for (i = 0; i <= hi; i++) {
      z[i] = static_cast<double>(i) + 1.0;
    }
  }
  b_z.set_size(z.size(1));
  hi = z.size(1);
  for (i = 0; i < hi; i++) {
    b_z[i] = (bz + 0.2) + dz * z[i];
  }
  // %%%%%% Despike %%%%%%%
  //  Find Spikes (phase-shift threshold, Shcherbina 2018)
  //  m, pulse distance
  //  Hz, pulse carrier frequency (1 MHz for Sig 1000)
  // NANMEAN Mean value, ignoring NaNs.
  //    M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
  //    values.  For vector input, M is the mean value of the non-NaN elements
  //    in X.  For matrix input, M is a row vector containing the mean value of
  //    non-NaN elements in each column.  For N-D arrays, NANMEAN operates
  //    along the first non-singleton dimension.
  //
  //    NANMEAN(X,DIM) takes the mean along dimension DIM of X.
  //
  //    See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.
  //    Copyright 1993-2004 The MathWorks, Inc.
  //    $Revision: 2.13.4.3 $  $Date: 2004/07/28 04:38:41 $
  //  Find NaNs and set them to zero
  nans = std::isnan(cs);
  bsum = cs;
  if (nans) {
    bsum = 0.0;
  }
  //  Count up non-NaNs.
  unnamed_idx_0 = !nans;
  if (nans) {
    unnamed_idx_0 = rtNaN;
  }
  //  prevent divideByZero warnings
  //  Sum up non-NaNs, and divide by the number of non-NaNs.
  if (std::isnan(bsum)) {
    bsum = 0.0;
  }
  bsum /= unnamed_idx_0;
  //  m/s
  //  1 m
  //  Identify Spikes
  coder::movmedian(wraw, std::round(1.0 / dz), wfilt);
  //  was medfilt1
  if ((wraw.size(0) == wfilt.size(0)) && (wraw.size(1) == wfilt.size(1))) {
    Z0.set_size(wraw.size(0), wraw.size(1));
    hi = wraw.size(0) * wraw.size(1);
    for (i = 0; i < hi; i++) {
      Z0[i] = wraw[i] - wfilt[i];
    }
    nx = Z0.size(0) * Z0.size(1);
    wfilt.set_size(Z0.size(0), Z0.size(1));
    for (int k{0}; k < nx; k++) {
      wfilt[k] = std::abs(Z0[k]);
    }
  } else {
    c_binary_expand_op(wfilt, wraw);
  }
  ispike.set_size(wfilt.size(0), wfilt.size(1));
  bsum = bsum * bsum /
         (4.0E+6 * (bz + dz * static_cast<double>(wraw.size(0)))) / 2.0;
  loop_ub_tmp = wfilt.size(0) * wfilt.size(1);
  for (i = 0; i < loop_ub_tmp; i++) {
    ispike[i] = (wfilt[i] > bsum);
  }
  //  Fill with linear interpolation
  winterp.set_size(wraw.size(0), wraw.size(1));
  hi = wraw.size(0) * wraw.size(1);
  for (i = 0; i < hi; i++) {
    winterp[i] = rtNaN;
  }
  i = wraw.size(1);
  for (nx = 0; nx < i; nx++) {
    hi = ispike.size(0);
    ifit.set_size(ispike.size(0));
    for (ib = 0; ib < hi; ib++) {
      ifit[ib] = !ispike[ib + ispike.size(0) * nx];
    }
    coder::eml_find(ifit, iidx);
    igood.set_size(iidx.size(0));
    hi = iidx.size(0);
    for (ib = 0; ib < hi; ib++) {
      igood[ib] = iidx[ib];
    }
    if (igood.size(0) > 3) {
      if (npages < 1) {
        n.set_size(1, 0);
      } else {
        n.set_size(1, npages);
        hi = npages - 1;
        for (ib = 0; ib <= hi; ib++) {
          n[ib] = static_cast<double>(ib) + 1.0;
        }
      }
      b_wraw.set_size(igood.size(0));
      hi = igood.size(0);
      for (ib = 0; ib < hi; ib++) {
        b_wraw[ib] =
            wraw[(static_cast<int>(igood[ib]) + wraw.size(0) * nx) - 1];
      }
      coder::interp1(igood, b_wraw, n, x);
      hi = winterp.size(0);
      for (ib = 0; ib < hi; ib++) {
        winterp[ib + winterp.size(0) * nx] = x[ib];
      }
    }
  }
  // %%%%% EOF High-pass %%%%%%
  //  Identify badpings with greater than 50% spikes
  //
  //  Compute EOFs from good pings
  // [eofs,alpha,~,~] = eof(winterp(:,~badping)');
  coder::combineVectorElements(ispike, r);
  npages = r.size(1) - 1;
  xpageoffset = 0;
  for (hi = 0; hi <= npages; hi++) {
    if (!(static_cast<double>(r[hi]) / static_cast<double>(wraw.size(0)) >
          0.5)) {
      xpageoffset++;
    }
  }
  r1.set_size(1, xpageoffset);
  nblocks = 0;
  for (hi = 0; hi <= npages; hi++) {
    if (!(static_cast<double>(r[hi]) / static_cast<double>(wraw.size(0)) >
          0.5)) {
      r1[nblocks] = hi;
      nblocks++;
    }
  }
  X.set_size(r1.size(1), winterp.size(0));
  hi = winterp.size(0);
  for (i = 0; i < hi; i++) {
    nblocks = r1.size(1);
    for (ib = 0; ib < nblocks; ib++) {
      X[ib + X.size(0) * i] = winterp[i + winterp.size(0) * r1[ib]];
    }
  }
  //  [nsamp,~] = size(X);
  wfilt.set_size(X.size(0), X.size(1));
  b_loop_ub_tmp = X.size(0) * X.size(1);
  for (i = 0; i < b_loop_ub_tmp; i++) {
    wfilt[i] = X[i];
  }
  // NANMEAN Mean value, ignoring NaNs.
  //    M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
  //    values.  For vector input, M is the mean value of the non-NaN elements
  //    in X.  For matrix input, M is a row vector containing the mean value of
  //    non-NaN elements in each column.  For N-D arrays, NANMEAN operates
  //    along the first non-singleton dimension.
  //
  //    NANMEAN(X,DIM) takes the mean along dimension DIM of X.
  //
  //    See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.
  //    Copyright 1993-2004 The MathWorks, Inc.
  //    $Revision: 2.13.4.3 $  $Date: 2004/07/28 04:38:41 $
  //  Find NaNs and set them to zero
  b_nans.set_size(X.size(0), X.size(1));
  for (i = 0; i < b_loop_ub_tmp; i++) {
    b_nans[i] = std::isnan(X[i]);
  }
  npages = b_loop_ub_tmp - 1;
  for (hi = 0; hi <= npages; hi++) {
    if (b_nans[hi]) {
      wfilt[hi] = 0.0;
    }
  }
  //  let sum deal with figuring out which dimension to use
  //  Count up non-NaNs.
  c_nans.set_size(b_nans.size(0), b_nans.size(1));
  for (i = 0; i < b_loop_ub_tmp; i++) {
    c_nans[i] = !b_nans[i];
  }
  coder::combineVectorElements(c_nans, r);
  n.set_size(1, r.size(1));
  hi = r.size(1);
  for (i = 0; i < hi; i++) {
    n[i] = r[i];
  }
  npages = n.size(1) - 1;
  for (hi = 0; hi <= npages; hi++) {
    if (n[hi] == 0.0) {
      n[hi] = rtNaN;
    }
  }
  //  prevent divideByZero warnings
  //  Sum up non-NaNs, and divide by the number of non-NaNs.
  if ((wfilt.size(0) == 0) || (wfilt.size(1) == 0)) {
    hi = wfilt.size(1);
    x.set_size(1, wfilt.size(1));
    for (i = 0; i < hi; i++) {
      x[i] = 0.0;
    }
  } else {
    npages = wfilt.size(1);
    x.set_size(1, wfilt.size(1));
    if (wfilt.size(0) <= 1024) {
      nx = wfilt.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      nx = 1024;
      nblocks =
          static_cast<int>(static_cast<unsigned int>(wfilt.size(0)) >> 10);
      lastBlockLength = wfilt.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (int xi{0}; xi < npages; xi++) {
      xpageoffset = xi * wfilt.size(0);
      x[xi] = wfilt[xpageoffset];
      for (int k{2}; k <= nx; k++) {
        x[xi] = x[xi] + wfilt[(xpageoffset + k) - 1];
      }
      for (ib = 2; ib <= nblocks; ib++) {
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        bsum = wfilt[xblockoffset];
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (int k{2}; k <= hi; k++) {
          bsum += wfilt[(xblockoffset + k) - 1];
        }
        x[xi] = x[xi] + bsum;
      }
    }
  }
  //  X0 = repmat(Xm,nsamp,1);
  if (x.size(1) == 1) {
    i = n.size(1);
  } else {
    i = x.size(1);
  }
  if ((x.size(1) == n.size(1)) && (X.size(1) == i)) {
    Z0.set_size(X.size(0), X.size(1));
    hi = X.size(1);
    for (i = 0; i < hi; i++) {
      nblocks = X.size(0);
      for (ib = 0; ib < nblocks; ib++) {
        Z0[ib + Z0.size(0) * i] = X[ib + X.size(0) * i] - x[i] / n[i];
      }
    }
    X.set_size(Z0.size(0), Z0.size(1));
    for (i = 0; i < b_loop_ub_tmp; i++) {
      X[i] = Z0[i];
    }
  } else {
    b_binary_expand_op(X, x, n);
  }
  // inan = isnan(X);
  xblockoffset = X.size(0) * X.size(1);
  npages = xblockoffset - 1;
  for (hi = 0; hi <= npages; hi++) {
    if (std::isnan(X[hi])) {
      X[hi] = 0.0;
    }
  }
  coder::internal::blas::mtimes(X, X, b_wfilt);
  coder::eig(b_wfilt, EOFs, E);
  coder::internal::sort(E, iidx);
  eofs.set_size(EOFs.size(0), iidx.size(0));
  hi = iidx.size(0);
  for (i = 0; i < hi; i++) {
    nblocks = EOFs.size(0);
    for (ib = 0; ib < nblocks; ib++) {
      eofs[ib + eofs.size(0) * i] = EOFs[ib + EOFs.size(0) * (iidx[i] - 1)];
    }
  }
  b_X.set_size(X.size(0), X.size(1));
  for (i = 0; i < xblockoffset; i++) {
    b_X[i].re = X[i];
    b_X[i].im = 0.0;
  }
  alpha.set_size(b_X.size(0), eofs.size(1));
  hi = b_X.size(0);
  for (i = 0; i < hi; i++) {
    nblocks = eofs.size(1);
    for (ib = 0; ib < nblocks; ib++) {
      alpha[i + alpha.size(0) * ib].re = 0.0;
      alpha[i + alpha.size(0) * ib].im = 0.0;
      npages = b_X.size(1);
      for (xpageoffset = 0; xpageoffset < npages; xpageoffset++) {
        double X_re_tmp;
        double b_X_re_tmp;
        bsum = b_X[i + b_X.size(0) * xpageoffset].re;
        unnamed_idx_0 = eofs[xpageoffset + eofs.size(0) * ib].im;
        X_re_tmp = b_X[i + b_X.size(0) * xpageoffset].im;
        b_X_re_tmp = eofs[xpageoffset + eofs.size(0) * ib].re;
        alpha[i + alpha.size(0) * ib].re =
            alpha[i + alpha.size(0) * ib].re +
            (bsum * b_X_re_tmp - X_re_tmp * unnamed_idx_0);
        alpha[i + alpha.size(0) * ib].im =
            alpha[i + alpha.size(0) * ib].im +
            (bsum * unnamed_idx_0 + X_re_tmp * b_X_re_tmp);
      }
    }
  }
  //  Reconstruct w/high-mode EOFs
  hi = winterp.size(0);
  wfilt.set_size(winterp.size(0), winterp.size(1));
  nblocks = winterp.size(0) * winterp.size(1);
  for (i = 0; i < nblocks; i++) {
    wfilt[i] = rtNaN;
  }
  if (neoflp + 1.0 > iidx.size(0)) {
    i = 0;
    ib = 0;
  } else {
    i = static_cast<int>(neoflp + 1.0) - 1;
    ib = iidx.size(0);
  }
  if (neoflp + 1.0 > alpha.size(1)) {
    xpageoffset = 0;
    nx = 0;
  } else {
    xpageoffset = static_cast<int>(neoflp + 1.0) - 1;
    nx = alpha.size(1);
  }
  iidx.set_size(r1.size(1));
  nblocks = r1.size(1);
  for (lastBlockLength = 0; lastBlockLength < nblocks; lastBlockLength++) {
    iidx[lastBlockLength] = r1[lastBlockLength];
  }
  npages = EOFs.size(0);
  b_loop_ub_tmp = ib - i;
  for (ib = 0; ib < b_loop_ub_tmp; ib++) {
    for (lastBlockLength = 0; lastBlockLength < npages; lastBlockLength++) {
      eofs[lastBlockLength + npages * ib] =
          eofs[lastBlockLength + eofs.size(0) * (i + ib)];
    }
  }
  eofs.set_size(EOFs.size(0), b_loop_ub_tmp);
  npages = alpha.size(0);
  b_loop_ub_tmp = nx - xpageoffset;
  for (i = 0; i < b_loop_ub_tmp; i++) {
    for (ib = 0; ib < npages; ib++) {
      alpha[ib + npages * i] = alpha[ib + alpha.size(0) * (xpageoffset + i)];
    }
  }
  alpha.set_size(alpha.size(0), b_loop_ub_tmp);
  coder::internal::blas::mtimes(eofs, alpha, EOFs);
  Z0.set_size(EOFs.size(0), EOFs.size(1));
  nblocks = EOFs.size(0) * EOFs.size(1);
  for (i = 0; i < nblocks; i++) {
    Z0[i] = EOFs[i].re;
  }
  npages = winterp.size(0);
  nblocks = iidx.size(0);
  for (i = 0; i < nblocks; i++) {
    for (ib = 0; ib < hi; ib++) {
      wfilt[ib + wfilt.size(0) * iidx[i]] = Z0[ib + npages * i];
    }
  }
  //  Remove spikes
  npages = loop_ub_tmp - 1;
  for (hi = 0; hi <= npages; hi++) {
    if (ispike[hi]) {
      wfilt[hi] = rtNaN;
    }
  }
  // %%%%% Compute Dissipation Rate %%%%%%
  //  Matrices of all possible data pair separation distances (R), and
  //  corresponding mean vertical position (Z0)
  z.set_size(1, z.size(1));
  loop_ub_tmp = z.size(1) - 1;
  for (i = 0; i <= loop_ub_tmp; i++) {
    z[i] = (bz + 0.2) + dz * z[i];
  }
  n.set_size(1, b_z.size(0));
  hi = b_z.size(0);
  for (i = 0; i < hi; i++) {
    n[i] = b_z[i];
  }
  coder::diff(n, x);
  dz = coder::mean(x);
  // R = round(R,2);
  X.set_size(z.size(1), z.size(1));
  hi = z.size(1);
  for (i = 0; i < hi; i++) {
    nblocks = z.size(1);
    for (ib = 0; ib < nblocks; ib++) {
      X[ib + X.size(0) * i] = (z[i] - z[ib]) * 100.0;
    }
  }
  npages = X.size(0) * X.size(1);
  for (int k{0}; k < npages; k++) {
    X[k] = std::round(X[k]);
  }
  for (i = 0; i < npages; i++) {
    X[i] = X[i] / 100.0;
  }
  n.set_size(1, b_z.size(0));
  hi = b_z.size(0);
  for (i = 0; i < hi; i++) {
    n[i] = b_z[i];
  }
  nx = n.size(1) - 1;
  Z0.set_size(n.size(1), n.size(1));
  winterp.set_size(n.size(1), n.size(1));
  if (n.size(1) != 0) {
    for (npages = 0; npages <= nx; npages++) {
      for (hi = 0; hi <= nx; hi++) {
        Z0[hi + Z0.size(0) * npages] = n[npages];
        winterp[hi + winterp.size(0) * npages] = n[hi];
      }
    }
  }
  if ((Z0.size(0) == winterp.size(0)) && (Z0.size(1) == winterp.size(1))) {
    hi = Z0.size(0) * Z0.size(1);
    for (i = 0; i < hi; i++) {
      Z0[i] = (Z0[i] + winterp[i]) / 2.0;
    }
  } else {
    b_binary_expand_op(Z0, winterp);
  }
  //  Matrices of all possible data pair velocity differences for each ping.
  coder::mean(wfilt, igood);
  if (wfilt.size(0) == igood.size(0)) {
    b_wfilt.set_size(wfilt.size(0), wfilt.size(1));
    hi = wfilt.size(1);
    for (i = 0; i < hi; i++) {
      nblocks = wfilt.size(0);
      for (ib = 0; ib < nblocks; ib++) {
        b_wfilt[ib + b_wfilt.size(0) * i] =
            wfilt[ib + wfilt.size(0) * i] - igood[ib];
      }
    }
    wfilt.set_size(b_wfilt.size(0), b_wfilt.size(1));
    hi = b_wfilt.size(1);
    for (i = 0; i < hi; i++) {
      nblocks = b_wfilt.size(0);
      for (ib = 0; ib < nblocks; ib++) {
        wfilt[ib + wfilt.size(0) * i] = b_wfilt[ib + b_wfilt.size(0) * i];
      }
    }
    coder::repmat(wfilt, static_cast<double>(wraw.size(0)), dW);
  } else {
    b_binary_expand_op(dW, wfilt, igood, wraw);
  }
  coder::permute(dW, r2);
  coder::b_permute(dW, r3);
  if ((r2.size(0) == r3.size(0)) && (r2.size(1) == r3.size(1)) &&
      (r2.size(2) == r3.size(2))) {
    dW.set_size(r2.size(0), r2.size(1), r2.size(2));
    hi = r2.size(0) * r2.size(1) * r2.size(2);
    for (i = 0; i < hi; i++) {
      dW[i] = r2[i] - r3[i];
    }
  } else {
    minus(dW, r2, r3);
  }
  coder::b_std(dW, wfilt);
  hi = wfilt.size(0) * wfilt.size(1);
  for (i = 0; i < hi; i++) {
    wfilt[i] = 5.0 * wfilt[i];
  }
  nx = dW.size(0) * dW.size(1) * dW.size(2);
  r2.set_size(dW.size(0), dW.size(1), dW.size(2));
  for (int k{0}; k < nx; k++) {
    r2[k] = std::abs(dW[k]);
  }
  if ((r2.size(0) == wfilt.size(0)) && (r2.size(1) == wfilt.size(1))) {
    nx = wfilt.size(0);
    r4.set_size(r2.size(0), r2.size(1), r2.size(2));
    hi = r2.size(2);
    for (i = 0; i < hi; i++) {
      nblocks = r2.size(1);
      for (ib = 0; ib < nblocks; ib++) {
        npages = r2.size(0);
        for (xpageoffset = 0; xpageoffset < npages; xpageoffset++) {
          r4[(xpageoffset + r4.size(0) * ib) + r4.size(0) * r4.size(1) * i] =
              (r2[(xpageoffset + r2.size(0) * ib) +
                  r2.size(0) * r2.size(1) * i] > wfilt[xpageoffset + nx * ib]);
        }
      }
    }
  } else {
    binary_expand_op(r4, r2, wfilt);
  }
  npages = r4.size(0) * (r4.size(1) * r4.size(2)) - 1;
  for (hi = 0; hi <= npages; hi++) {
    if (r4[hi]) {
      dW[hi] = rtNaN;
    }
  }
  //  Take mean (or median, or mean-of-the-logs) squared velocity difference to
  //  get D(z,r)
  if (coder::internal::b_strcmp(avgtype)) {
    r2.set_size(dW.size(0), dW.size(1), dW.size(2));
    hi = dW.size(0) * dW.size(1) * dW.size(2);
    for (i = 0; i < hi; i++) {
      bsum = dW[i];
      r2[i] = bsum * bsum;
    }
    coder::mean(r2, D);
  } else if (coder::internal::c_strcmp(avgtype)) {
    b_loop_ub_tmp = dW.size(0) * dW.size(1) * dW.size(2);
    for (i = 0; i < b_loop_ub_tmp; i++) {
      bsum = dW[i];
      dW[i] = bsum * bsum;
    }
    for (int k{0}; k < b_loop_ub_tmp; k++) {
      dW[k] = std::log10(dW[k]);
    }
    coder::mean(dW, wfilt);
    D.set_size(wfilt.size(0), wfilt.size(1));
    hi = wfilt.size(0) * wfilt.size(1);
    for (i = 0; i < hi; i++) {
      bsum = wfilt[i];
      D[i] = rt_powd_snf(10.0, bsum);
    }
  }
  // Fit structure function to theoretical curve
  eps.set_size(1, b_z.size(0));
  hi = b_z.size(0);
  for (i = 0; i < hi; i++) {
    eps[i] = rtNaN;
  }
  n.set_size(1, b_z.size(0));
  hi = b_z.size(0);
  for (i = 0; i < hi; i++) {
    n[i] = rtNaN;
  }
  i = z.size(1);
  for (int xi{0}; xi < i; xi++) {
    // Find points in z0 bin
    npages = Z0.size(0) * Z0.size(1) - 1;
    xpageoffset = 0;
    for (hi = 0; hi <= npages; hi++) {
      bsum = z[xi];
      unnamed_idx_0 = 1.1 * nzfit * dz / 2.0;
      if ((Z0[hi] >= bsum - unnamed_idx_0) &&
          (Z0[hi] <= bsum + unnamed_idx_0)) {
        xpageoffset++;
      }
    }
    r5.set_size(xpageoffset);
    nblocks = 0;
    for (hi = 0; hi <= npages; hi++) {
      bsum = z[xi];
      unnamed_idx_0 = 1.1 * nzfit * dz / 2.0;
      if ((Z0[hi] >= bsum - unnamed_idx_0) &&
          (Z0[hi] <= bsum + unnamed_idx_0)) {
        r5[nblocks] = hi;
        nblocks++;
      }
    }
    hi = r5.size(0);
    igood.set_size(r5.size(0));
    for (ib = 0; ib < hi; ib++) {
      igood[ib] = X[r5[ib]];
    }
    coder::internal::sort(igood, iidx);
    b_z.set_size(iidx.size(0));
    hi = iidx.size(0);
    for (ib = 0; ib < hi; ib++) {
      b_z[ib] = D[r5[iidx[ib] - 1]];
    }
    // Select points within specified separation scale range
    ifit.set_size(igood.size(0));
    hi = igood.size(0);
    for (ib = 0; ib < hi; ib++) {
      ifit[ib] = ((igood[ib] <= rmax) && (igood[ib] >= rmin));
    }
    npages = igood.size(0);
    if (igood.size(0) == 0) {
      lastBlockLength = 0;
    } else {
      lastBlockLength = ((igood[0] <= rmax) && (igood[0] >= rmin));
      for (int k{2}; k <= npages; k++) {
        bsum = igood[k - 1];
        lastBlockLength += ((bsum <= rmax) && (bsum >= rmin));
      }
    }
    npages = igood.size(0);
    if (igood.size(0) == 0) {
      nx = 0;
    } else {
      nx = ((igood[0] <= rmax) && (igood[0] >= rmin));
      for (int k{2}; k <= npages; k++) {
        bsum = igood[k - 1];
        nx += ((bsum <= rmax) && (bsum >= rmin));
      }
    }
    if (nx >= 3) {
      int exitg1;
      xblockoffset = igood.size(0) - 1;
      xpageoffset = 0;
      for (hi = 0; hi <= xblockoffset; hi++) {
        if ((igood[hi] <= rmax) && (igood[hi] >= rmin)) {
          xpageoffset++;
        }
      }
      nblocks = 0;
      for (hi = 0; hi <= xblockoffset; hi++) {
        if ((igood[hi] <= rmax) && (igood[hi] >= rmin)) {
          bsum = igood[hi];
          igood[nblocks] = rt_powd_snf(bsum, 0.66666666666666663);
          nblocks++;
        }
      }
      igood.set_size(xpageoffset);
      // Fit Structure function to theoretical curves
      nans = false;
      if (fittype.size(1) == 5) {
        npages = 0;
        do {
          exitg1 = 0;
          if (npages < 5) {
            if (fittype[npages] != cv[npages]) {
              exitg1 = 1;
            } else {
              npages++;
            }
          } else {
            nans = true;
            exitg1 = 1;
          }
        } while (exitg1 == 0);
      }
      if (nans) {
        double C[3];
        //  Fit structure function to D(z,r) = Br^2 + Ar^(2/3) + N
        G.set_size(xpageoffset, 3);
        for (ib = 0; ib < xpageoffset; ib++) {
          bsum = igood[ib];
          G[ib] = rt_powd_snf(bsum, 3.0);
          G[ib + G.size(0)] = igood[ib];
        }
        for (ib = 0; ib < lastBlockLength; ib++) {
          G[ib + G.size(0) * 2] = 1.0;
        }
        c_G.set_size(3, G.size(0));
        hi = G.size(0);
        for (ib = 0; ib < hi; ib++) {
          c_G[3 * ib] = G[ib];
          c_G[3 * ib + 1] = G[ib + G.size(0)];
          c_G[3 * ib + 2] = G[ib + G.size(0) * 2];
        }
        double dv[9];
        coder::internal::blas::mtimes(G, G, dv);
        coder::mldivide(dv, c_G, A);
        npages = A.size(1);
        C[0] = 0.0;
        C[1] = 0.0;
        C[2] = 0.0;
        for (int k{0}; k < npages; k++) {
          nx = k * 3;
          for (hi = 0; hi < 3; hi++) {
            xpageoffset = 0;
            for (lastBlockLength = 0; lastBlockLength <= xblockoffset;
                 lastBlockLength++) {
              if (ifit[lastBlockLength]) {
                xpageoffset++;
              }
            }
            r7.set_size(xpageoffset);
            nblocks = 0;
            for (lastBlockLength = 0; lastBlockLength <= xblockoffset;
                 lastBlockLength++) {
              if (ifit[lastBlockLength]) {
                r7[nblocks] = lastBlockLength;
                nblocks++;
              }
            }
            C[hi] += A[nx + hi] * b_z[r7[k]];
          }
        }
        n[xi] = C[1];
      } else {
        nans = false;
        if (fittype.size(1) == 6) {
          npages = 0;
          do {
            exitg1 = 0;
            if (npages < 6) {
              if (fittype[npages] != cv1[npages]) {
                exitg1 = 1;
              } else {
                npages++;
              }
            } else {
              nans = true;
              exitg1 = 1;
            }
          } while (exitg1 == 0);
        }
        if (nans) {
          double sz[2];
          //  Fit structure function to D(z,r) = Ar^(2/3) + N
          b_G.set_size(xpageoffset, 2);
          for (ib = 0; ib < xpageoffset; ib++) {
            b_G[ib] = igood[ib];
          }
          for (ib = 0; ib < lastBlockLength; ib++) {
            b_G[ib + b_G.size(0)] = 1.0;
          }
          d_G.set_size(2, b_G.size(0));
          hi = b_G.size(0);
          for (ib = 0; ib < hi; ib++) {
            d_G[2 * ib] = b_G[ib];
            d_G[2 * ib + 1] = b_G[ib + b_G.size(0)];
          }
          double dv1[4];
          coder::internal::blas::b_mtimes(b_G, b_G, dv1);
          coder::b_mldivide(dv1, d_G, b_A);
          npages = b_A.size(1);
          sz[0] = 0.0;
          sz[1] = 0.0;
          for (int k{0}; k < npages; k++) {
            nx = k << 1;
            for (hi = 0; hi < 2; hi++) {
              xpageoffset = 0;
              for (lastBlockLength = 0; lastBlockLength <= xblockoffset;
                   lastBlockLength++) {
                if (ifit[lastBlockLength]) {
                  xpageoffset++;
                }
              }
              r8.set_size(xpageoffset);
              nblocks = 0;
              for (lastBlockLength = 0; lastBlockLength <= xblockoffset;
                   lastBlockLength++) {
                if (ifit[lastBlockLength]) {
                  r8[nblocks] = lastBlockLength;
                  nblocks++;
                }
              }
              sz[hi] += b_A[nx + hi] * b_z[r8[k]];
            }
          }
          n[xi] = sz[0];
        } else {
          nans = false;
          if (fittype.size(1) == 3) {
            npages = 0;
            do {
              exitg1 = 0;
              if (npages < 3) {
                if (fittype[npages] != cv2[npages]) {
                  exitg1 = 1;
                } else {
                  npages++;
                }
              } else {
                nans = true;
                exitg1 = 1;
              }
            } while (exitg1 == 0);
          }
          if (nans) {
            double sz[2];
            //  Don't presume a slope
            npages = xpageoffset - 1;
            xpageoffset = 0;
            for (hi = 0; hi <= npages; hi++) {
              if (igood[hi] > 0.0) {
                xpageoffset++;
              }
            }
            r6.set_size(xpageoffset);
            nblocks = 0;
            for (hi = 0; hi <= npages; hi++) {
              if (igood[hi] > 0.0) {
                r6[nblocks] = hi;
                nblocks++;
              }
            }
            hi = r6.size(0);
            b_wraw.set_size(r6.size(0));
            for (ib = 0; ib < hi; ib++) {
              b_wraw[ib] = igood[r6[ib]];
            }
            igood.set_size(b_wraw.size(0));
            hi = b_wraw.size(0);
            for (ib = 0; ib < hi; ib++) {
              igood[ib] = b_wraw[ib];
            }
            nx = igood.size(0);
            for (int k{0}; k < nx; k++) {
              igood[k] = std::log10(igood[k]);
            }
            b_G.set_size(igood.size(0), 2);
            hi = igood.size(0);
            for (ib = 0; ib < hi; ib++) {
              b_G[ib] = igood[ib];
              b_G[ib + b_G.size(0)] = 1.0;
            }
            xpageoffset = 0;
            for (hi = 0; hi <= xblockoffset; hi++) {
              if (ifit[hi]) {
                xpageoffset++;
              }
            }
            r9.set_size(xpageoffset);
            nblocks = 0;
            for (hi = 0; hi <= xblockoffset; hi++) {
              if (ifit[hi]) {
                r9[nblocks] = hi;
                nblocks++;
              }
            }
            hi = r6.size(0);
            igood.set_size(r6.size(0));
            d_G.set_size(2, b_G.size(0));
            for (int k{0}; k < hi; k++) {
              igood[k] = std::log10(b_z[r9[r6[k]]]);
              d_G[2 * k] = b_G[k];
              d_G[2 * k + 1] = b_G[k + b_G.size(0)];
            }
            double dv1[4];
            coder::internal::blas::b_mtimes(b_G, b_G, dv1);
            coder::b_mldivide(dv1, d_G, b_A);
            npages = b_A.size(1);
            sz[1] = 0.0;
            for (int k{0}; k < npages; k++) {
              sz[1] += b_A[(k << 1) + 1] * igood[k];
            }
            n[xi] = rt_powd_snf(10.0, sz[1]);
          }
        }
      }
      eps[xi] = rt_powd_snf(n[xi] / 2.1, 1.5);
    } else {
      //  Must contain more than 3 points
    }
  }
  //  Remove unphysical values
  for (hi = 0; hi <= loop_ub_tmp; hi++) {
    if (n[hi] < 0.0) {
      eps[hi] = rtNaN;
    }
  }
}

// End of code generation (processSIGburst_onboard.cpp)
