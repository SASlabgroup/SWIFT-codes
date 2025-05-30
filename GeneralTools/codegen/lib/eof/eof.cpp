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
#include "eof_data.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
void eof(coder::array<double, 2U> &X, coder::array<creal_T, 2U> &EOFs,
         coder::array<creal_T, 2U> &alpha, coder::array<creal_T, 2U> &E,
         coder::array<double, 2U> &Xm)
{
  coder::array<creal_T, 2U> b_EOFs;
  coder::array<creal_T, 1U> b_E;
  coder::array<double, 2U> X0;
  coder::array<double, 2U> n;
  coder::array<int, 2U> nz;
  coder::array<int, 1U> iidx;
  coder::array<int, 1U> r;
  coder::array<bool, 2U> nans;
  double bsum;
  double bsum_im;
  double y_im;
  double y_re;
  int hi;
  int i;
  int ib;
  int k;
  int lastBlockLength;
  int nblocks;
  int npages;
  int vlen;
  int xblockoffset;
  int xpageoffset;
  //  [EOFs,alpha,E] = eof(X) calculates basic EOF components
  //    Columns of X are timeseries. NaN replaced w/0 for covariance
  //    calculation. Xm is the mean removed to compute the EOFs.
  // Remove the time mean of each column
  X0.set_size(X.size(0), X.size(1));
  vlen = X.size(0) * X.size(1);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
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
  nans.set_size(X.size(0), X.size(1));
  vlen = X.size(0) * X.size(1);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    nans[xpageoffset] = std::isnan(X[xpageoffset]);
  }
  nblocks = nans.size(0) * nans.size(1) - 1;
  vlen = 0;
  for (i = 0; i <= nblocks; i++) {
    if (nans[i]) {
      vlen++;
    }
  }
  iidx.set_size(vlen);
  vlen = 0;
  for (i = 0; i <= nblocks; i++) {
    if (nans[i]) {
      iidx[vlen] = i + 1;
      vlen++;
    }
  }
  vlen = iidx.size(0);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    X0[iidx[xpageoffset] - 1] = 0.0;
  }
  //  let sum deal with figuring out which dimension to use
  //  Count up non-NaNs.
  vlen = nans.size(0) * nans.size(1);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    nans[xpageoffset] = !nans[xpageoffset];
  }
  vlen = nans.size(0);
  if ((nans.size(0) == 0) || (nans.size(1) == 0)) {
    nz.set_size(1, nans.size(1));
    vlen = nans.size(1);
    for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
      nz[xpageoffset] = 0;
    }
  } else {
    npages = nans.size(1);
    nz.set_size(1, nans.size(1));
    for (i = 0; i < npages; i++) {
      xpageoffset = i * nans.size(0);
      nz[i] = nans[xpageoffset];
      for (k = 2; k <= vlen; k++) {
        nz[i] = nz[i] + nans[(xpageoffset + k) - 1];
      }
    }
  }
  n.set_size(1, nz.size(1));
  vlen = nz.size(1);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    n[xpageoffset] = nz[xpageoffset];
  }
  nblocks = n.size(1);
  for (i = 0; i < nblocks; i++) {
    if (n[i] == 0.0) {
      n[i] = rtNaN;
    }
  }
  //  prevent divideByZero warnings
  //  Sum up non-NaNs, and divide by the number of non-NaNs.
  if ((X0.size(0) == 0) || (X0.size(1) == 0)) {
    Xm.set_size(1, X0.size(1));
    vlen = X0.size(1);
    for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
      Xm[xpageoffset] = 0.0;
    }
  } else {
    npages = X0.size(1);
    Xm.set_size(1, X0.size(1));
    if (X0.size(0) <= 1024) {
      vlen = X0.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      vlen = 1024;
      nblocks = X0.size(0) / 1024;
      lastBlockLength = X0.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (i = 0; i < npages; i++) {
      xpageoffset = i * X0.size(0);
      Xm[i] = X0[xpageoffset];
      for (k = 2; k <= vlen; k++) {
        Xm[i] = Xm[i] + X0[(xpageoffset + k) - 1];
      }
      for (ib = 2; ib <= nblocks; ib++) {
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        bsum = X0[xblockoffset];
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (k = 2; k <= hi; k++) {
          bsum += X0[(xblockoffset + k) - 1];
        }
        Xm[i] = Xm[i] + bsum;
      }
    }
  }
  Xm.set_size(1, Xm.size(1));
  vlen = Xm.size(1) - 1;
  for (xpageoffset = 0; xpageoffset <= vlen; xpageoffset++) {
    Xm[xpageoffset] = Xm[xpageoffset] / n[xpageoffset];
  }
  X0.set_size(X.size(0), Xm.size(1));
  nblocks = Xm.size(1);
  vlen = X.size(0);
  for (xblockoffset = 0; xblockoffset < nblocks; xblockoffset++) {
    lastBlockLength = xblockoffset * vlen;
    for (hi = 0; hi < vlen; hi++) {
      X0[lastBlockLength + hi] = Xm[xblockoffset];
    }
  }
  vlen = X.size(0) * X.size(1);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    X[xpageoffset] = X[xpageoffset] - X0[xpageoffset];
  }
  // Sub NaN w/0
  nans.set_size(X.size(0), X.size(1));
  vlen = X.size(0) * X.size(1);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    nans[xpageoffset] = std::isnan(X[xpageoffset]);
  }
  nblocks = nans.size(0) * nans.size(1) - 1;
  vlen = 0;
  for (i = 0; i <= nblocks; i++) {
    if (nans[i]) {
      vlen++;
    }
  }
  r.set_size(vlen);
  vlen = 0;
  for (i = 0; i <= nblocks; i++) {
    if (nans[i]) {
      r[vlen] = i + 1;
      vlen++;
    }
  }
  vlen = r.size(0) - 1;
  for (xpageoffset = 0; xpageoffset <= vlen; xpageoffset++) {
    X[r[xpageoffset] - 1] = 0.0;
  }
  // Data-data covariance matrix:
  vlen = X.size(1);
  nblocks = X.size(0);
  lastBlockLength = X.size(1);
  X0.set_size(X.size(1), X.size(1));
  for (npages = 0; npages < lastBlockLength; npages++) {
    xblockoffset = npages * vlen;
    hi = npages * X.size(0);
    for (i = 0; i < vlen; i++) {
      X0[xblockoffset + i] = 0.0;
    }
    for (k = 0; k < nblocks; k++) {
      bsum = X[hi + k];
      for (i = 0; i < vlen; i++) {
        xpageoffset = xblockoffset + i;
        X0[xpageoffset] = X0[xpageoffset] + X[i * X.size(0) + k] * bsum;
      }
    }
  }
  // Eigenvectors are modes and eigenvalues are variance
  coder::eig(X0, b_EOFs, b_E);
  // Sort by EOF variance
  coder::internal::sort(b_E, iidx);
  vlen = b_EOFs.size(0);
  EOFs.set_size(b_EOFs.size(0), iidx.size(0));
  nblocks = iidx.size(0);
  for (xpageoffset = 0; xpageoffset < nblocks; xpageoffset++) {
    for (xblockoffset = 0; xblockoffset < vlen; xblockoffset++) {
      EOFs[xblockoffset + EOFs.size(0) * xpageoffset] =
          b_EOFs[xblockoffset + b_EOFs.size(0) * (iidx[xpageoffset] - 1)];
    }
  }
  // Fraction of variance explained by each mode
  if (b_E.size(0) == 0) {
    y_re = 0.0;
    y_im = 0.0;
  } else {
    if (b_E.size(0) <= 1024) {
      vlen = b_E.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      vlen = 1024;
      nblocks = b_E.size(0) / 1024;
      lastBlockLength = b_E.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    y_re = b_E[0].re;
    y_im = b_E[0].im;
    for (k = 2; k <= vlen; k++) {
      y_re += b_E[k - 1].re;
      y_im += b_E[k - 1].im;
    }
    for (ib = 2; ib <= nblocks; ib++) {
      xblockoffset = (ib - 1) << 10;
      bsum = b_E[xblockoffset].re;
      bsum_im = b_E[xblockoffset].im;
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (k = 2; k <= hi; k++) {
        vlen = (xblockoffset + k) - 1;
        bsum += b_E[vlen].re;
        bsum_im += b_E[vlen].im;
      }
      y_re += bsum;
      y_im += bsum_im;
    }
  }
  E.set_size(1, b_E.size(0));
  vlen = b_E.size(0);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    double E_re;
    double ai;
    double ar;
    ar = b_E[xpageoffset].re;
    ai = b_E[xpageoffset].im;
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
      double brm;
      brm = std::abs(y_re);
      bsum = std::abs(y_im);
      if (brm > bsum) {
        bsum = y_im / y_re;
        bsum_im = y_re + bsum * y_im;
        E_re = (ar + bsum * ai) / bsum_im;
        bsum = (ai - bsum * ar) / bsum_im;
      } else if (bsum == brm) {
        if (y_re > 0.0) {
          bsum = 0.5;
        } else {
          bsum = -0.5;
        }
        if (y_im > 0.0) {
          bsum_im = 0.5;
        } else {
          bsum_im = -0.5;
        }
        E_re = (ar * bsum + ai * bsum_im) / brm;
        bsum = (ai * bsum - ar * bsum_im) / brm;
      } else {
        bsum = y_re / y_im;
        bsum_im = y_im + bsum * y_re;
        E_re = (bsum * ar + ai) / bsum_im;
        bsum = (bsum * ai - ar) / bsum_im;
      }
    }
    E[xpageoffset].re = E_re;
    E[xpageoffset].im = -bsum;
  }
  // EOF amplitudes
  b_EOFs.set_size(X.size(0), X.size(1));
  vlen = X.size(0) * X.size(1);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    b_EOFs[xpageoffset].re = X[xpageoffset];
    b_EOFs[xpageoffset].im = 0.0;
  }
  alpha.set_size(b_EOFs.size(0), EOFs.size(1));
  vlen = b_EOFs.size(0);
  for (xpageoffset = 0; xpageoffset < vlen; xpageoffset++) {
    nblocks = EOFs.size(1);
    for (xblockoffset = 0; xblockoffset < nblocks; xblockoffset++) {
      alpha[xpageoffset + alpha.size(0) * xblockoffset].re = 0.0;
      alpha[xpageoffset + alpha.size(0) * xblockoffset].im = 0.0;
      lastBlockLength = b_EOFs.size(1);
      for (hi = 0; hi < lastBlockLength; hi++) {
        alpha[xpageoffset + alpha.size(0) * xblockoffset].re =
            alpha[xpageoffset + alpha.size(0) * xblockoffset].re +
            (b_EOFs[xpageoffset + b_EOFs.size(0) * hi].re *
                 EOFs[hi + EOFs.size(0) * xblockoffset].re -
             b_EOFs[xpageoffset + b_EOFs.size(0) * hi].im *
                 EOFs[hi + EOFs.size(0) * xblockoffset].im);
        alpha[xpageoffset + alpha.size(0) * xblockoffset].im =
            alpha[xpageoffset + alpha.size(0) * xblockoffset].im +
            (b_EOFs[xpageoffset + b_EOFs.size(0) * hi].re *
                 EOFs[hi + EOFs.size(0) * xblockoffset].im +
             b_EOFs[xpageoffset + b_EOFs.size(0) * hi].im *
                 EOFs[hi + EOFs.size(0) * xblockoffset].re);
      }
    }
  }
  //  inan = any(inan,2);
  //  alpha(repmat(inan,1,ndata)) = NaN;
  // EOF timeseries
  // Y = alpha(:,npick)*EOFs(:,npick)' + X0;
}

// End of code generation (eof.cpp)
