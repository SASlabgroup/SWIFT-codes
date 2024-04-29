//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eof.cpp
//
// Code generation for function 'eof'
//

// Include files
#include "eof.h"
#include "eig.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include "coder_array.h"
#include <cmath>
#include <cstring>

// Function Declarations
static void b_minus(coder::array<double, 2U> &in1,
                    const coder::array<double, 2U> &in2);

// Function Definitions
static void b_minus(coder::array<double, 2U> &in1,
                    const coder::array<double, 2U> &in2)
{
  coder::array<double, 2U> b_in1;
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  if (in2.size(0) == 1) {
    loop_ub = in1.size(0);
  } else {
    loop_ub = in2.size(0);
  }
  b_in1.set_size(loop_ub, 128);
  stride_0_0 = (in1.size(0) != 1);
  stride_1_0 = (in2.size(0) != 1);
  for (int i{0}; i < 128; i++) {
    for (int i1{0}; i1 < loop_ub; i1++) {
      b_in1[i1 + b_in1.size(0) * i] = in1[i1 * stride_0_0 + in1.size(0) * i] -
                                      in2[i1 * stride_1_0 + in2.size(0) * i];
    }
  }
  in1.set_size(b_in1.size(0), 128);
  loop_ub = b_in1.size(0);
  for (int i{0}; i < 128; i++) {
    for (int i1{0}; i1 < loop_ub; i1++) {
      in1[i1 + in1.size(0) * i] = b_in1[i1 + b_in1.size(0) * i];
    }
  }
}

void eof(coder::array<double, 2U> &X, creal_T EOFs[16384],
         coder::array<creal_T, 2U> &alpha, double Xm[128], creal_T E[128])
{
  static creal_T b_EOFs[16384];
  static double R[16384];
  coder::array<creal_T, 2U> b_X;
  coder::array<double, 2U> X0;
  double n[128];
  double E_re;
  double ar;
  double brm;
  double bsum;
  double d;
  double sgnbi;
  double y_im;
  double y_re;
  int nz[128];
  int hi;
  int lastBlockLength;
  int loop_ub_tmp;
  int nblocks;
  int vlen;
  int xblockoffset;
  int xpageoffset;
  //  [EOFs,alpha,E] = eof(X) calculates basic EOF components
  //    Columns of X are timeseries. NaN replaced w/0 for covariance
  //    calculation. Xm is the mean removed to compute the EOFs.
  // Remove the time mean of each column
  X0.set_size(X.size(0), 128);
  loop_ub_tmp = X.size(0) << 7;
  for (xpageoffset = 0; xpageoffset < loop_ub_tmp; xpageoffset++) {
    X0[xpageoffset] = X[xpageoffset];
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
  vlen = loop_ub_tmp - 1;
  for (int i{0}; i <= vlen; i++) {
    if (std::isnan(X[i])) {
      X0[i] = 0.0;
    }
  }
  //  let sum deal with figuring out which dimension to use
  //  Count up non-NaNs.
  vlen = X.size(0);
  if (X.size(0) == 0) {
    std::memset(&nz[0], 0, 128U * sizeof(int));
  } else {
    for (int i{0}; i < 128; i++) {
      xpageoffset = i * X.size(0);
      nz[i] = !std::isnan(X[xpageoffset]);
      for (int k{2}; k <= vlen; k++) {
        nz[i] += !std::isnan(X[(xpageoffset + k) - 1]);
      }
    }
  }
  for (int i{0}; i < 128; i++) {
    xpageoffset = nz[i];
    n[i] = xpageoffset;
    if (xpageoffset == 0) {
      n[i] = rtNaN;
    }
  }
  //  prevent divideByZero warnings
  //  Sum up non-NaNs, and divide by the number of non-NaNs.
  if (X0.size(0) == 0) {
    std::memset(&Xm[0], 0, 128U * sizeof(double));
  } else {
    if (X0.size(0) <= 1024) {
      vlen = X0.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      vlen = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(X0.size(0)) >> 10);
      lastBlockLength = X0.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (int i{0}; i < 128; i++) {
      xpageoffset = i * X0.size(0);
      Xm[i] = X0[xpageoffset];
      for (int k{2}; k <= vlen; k++) {
        Xm[i] += X0[(xpageoffset + k) - 1];
      }
      for (int ib{2}; ib <= nblocks; ib++) {
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        bsum = X0[xblockoffset];
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (int k{2}; k <= hi; k++) {
          bsum += X0[(xblockoffset + k) - 1];
        }
        Xm[i] += bsum;
      }
    }
  }
  X0.set_size(X.size(0), 128);
  vlen = X.size(0);
  for (lastBlockLength = 0; lastBlockLength < 128; lastBlockLength++) {
    Xm[lastBlockLength] /= n[lastBlockLength];
    nblocks = lastBlockLength * vlen;
    for (xblockoffset = 0; xblockoffset < vlen; xblockoffset++) {
      X0[nblocks + xblockoffset] = Xm[lastBlockLength];
    }
  }
  if (X.size(0) == X0.size(0)) {
    X.set_size(X.size(0), 128);
    for (xpageoffset = 0; xpageoffset < loop_ub_tmp; xpageoffset++) {
      X[xpageoffset] = X[xpageoffset] - X0[xpageoffset];
    }
  } else {
    b_minus(X, X0);
  }
  // Sub NaN w/0
  hi = X.size(0) << 7;
  vlen = hi - 1;
  for (int i{0}; i <= vlen; i++) {
    if (std::isnan(X[i])) {
      X[i] = 0.0;
    }
  }
  // Data-data covariance matrix:
  vlen = X.size(0);
  for (xpageoffset = 0; xpageoffset < 128; xpageoffset++) {
    nblocks = xpageoffset << 7;
    lastBlockLength = xpageoffset * X.size(0);
    std::memset(&R[nblocks], 0, 128U * sizeof(double));
    for (int k{0}; k < vlen; k++) {
      bsum = X[lastBlockLength + k];
      for (int i{0}; i < 128; i++) {
        xblockoffset = nblocks + i;
        R[xblockoffset] += X[i * X.size(0) + k] * bsum;
      }
    }
  }
  // Eigenvectors are modes and eigenvalues are variance
  coder::eig(R, b_EOFs, E);
  // Sort by EOF variance
  coder::internal::sort(E, nz);
  for (xpageoffset = 0; xpageoffset < 128; xpageoffset++) {
    for (xblockoffset = 0; xblockoffset < 128; xblockoffset++) {
      EOFs[xblockoffset + (xpageoffset << 7)] =
          b_EOFs[xblockoffset + ((nz[xpageoffset] - 1) << 7)];
    }
  }
  // Fraction of variance explained by each mode
  y_re = E[0].re;
  y_im = E[0].im;
  for (int k{0}; k < 127; k++) {
    y_re += E[k + 1].re;
    y_im += E[k + 1].im;
  }
  for (xpageoffset = 0; xpageoffset < 128; xpageoffset++) {
    double ai;
    ar = E[xpageoffset].re;
    ai = E[xpageoffset].im;
    if (y_im == 0.0) {
      if (ai == 0.0) {
        E_re = ar / y_re;
        bsum = 0.0;
      } else if (ar == 0.0) {
        E_re = 0.0;
        bsum = ai / y_re;
      } else {
        E_re = ar / y_re;
        bsum = ai / y_re;
      }
    } else if (y_re == 0.0) {
      if (ar == 0.0) {
        E_re = ai / y_im;
        bsum = 0.0;
      } else if (ai == 0.0) {
        E_re = 0.0;
        bsum = -(ar / y_im);
      } else {
        E_re = ai / y_im;
        bsum = -(ar / y_im);
      }
    } else {
      brm = std::abs(y_re);
      bsum = std::abs(y_im);
      if (brm > bsum) {
        bsum = y_im / y_re;
        d = y_re + bsum * y_im;
        E_re = (ar + bsum * ai) / d;
        bsum = (ai - bsum * ar) / d;
      } else if (bsum == brm) {
        if (y_re > 0.0) {
          bsum = 0.5;
        } else {
          bsum = -0.5;
        }
        if (y_im > 0.0) {
          sgnbi = 0.5;
        } else {
          sgnbi = -0.5;
        }
        E_re = (ar * bsum + ai * sgnbi) / brm;
        bsum = (ai * bsum - ar * sgnbi) / brm;
      } else {
        bsum = y_re / y_im;
        d = y_im + bsum * y_re;
        E_re = (bsum * ar + ai) / d;
        bsum = (bsum * ai - ar) / d;
      }
    }
    E[xpageoffset].re = E_re;
    E[xpageoffset].im = -bsum;
  }
  // EOF amplitudes
  b_X.set_size(X.size(0), 128);
  for (xpageoffset = 0; xpageoffset < hi; xpageoffset++) {
    b_X[xpageoffset].re = X[xpageoffset];
    b_X[xpageoffset].im = 0.0;
  }
  alpha.set_size(b_X.size(0), 128);
  vlen = b_X.size(0);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    for (xblockoffset = 0; xblockoffset < 128; xblockoffset++) {
      bsum = 0.0;
      d = 0.0;
      for (lastBlockLength = 0; lastBlockLength < 128; lastBlockLength++) {
        sgnbi = b_X[xpageoffset + b_X.size(0) * lastBlockLength].re;
        nblocks = lastBlockLength + (xblockoffset << 7);
        brm = EOFs[nblocks].im;
        E_re = b_X[xpageoffset + b_X.size(0) * lastBlockLength].im;
        ar = EOFs[nblocks].re;
        bsum += sgnbi * ar - E_re * brm;
        d += sgnbi * brm + E_re * ar;
      }
      alpha[xpageoffset + alpha.size(0) * xblockoffset].re = bsum;
      alpha[xpageoffset + alpha.size(0) * xblockoffset].im = d;
    }
  }
  //  inan = any(inan,2);
  //  alpha(repmat(inan,1,ndata)) = NaN;
  // EOF timeseries
  // Y = alpha(:,npick)*EOFs(:,npick)' + X0;
}

// End of code generation (eof.cpp)
