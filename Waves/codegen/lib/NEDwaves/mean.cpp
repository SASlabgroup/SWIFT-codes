//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mean.cpp
//
// Code generation for function 'mean'
//

// Include files
#include "mean.h"
#include "NEDwaves_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
void mean(const ::coder::array<double, 2U> &x, ::coder::array<double, 2U> &y)
{
  int firstBlockLength;
  int npages;
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    y.set_size(1, x.size(1));
    npages = x.size(1);
    for (firstBlockLength = 0; firstBlockLength < npages; firstBlockLength++) {
      y[firstBlockLength] = 0.0;
    }
  } else {
    int lastBlockLength;
    int nblocks;
    npages = x.size(1);
    y.set_size(1, x.size(1));
    if (x.size(0) <= 1024) {
      firstBlockLength = x.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x.size(0) >> 10;
      lastBlockLength = x.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (int xi{0}; xi < npages; xi++) {
      int xpageoffset;
      xpageoffset = xi * x.size(0);
      y[xi] = x[xpageoffset];
      for (int k{2}; k <= firstBlockLength; k++) {
        y[xi] = y[xi] + x[(xpageoffset + k) - 1];
      }
      for (int ib{2}; ib <= nblocks; ib++) {
        double bsum;
        int hi;
        int xblockoffset;
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        bsum = x[xblockoffset];
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (int k{2}; k <= hi; k++) {
          bsum += x[(xblockoffset + k) - 1];
        }
        y[xi] = y[xi] + bsum;
      }
    }
  }
  y.set_size(1, y.size(1));
  npages = y.size(1) - 1;
  for (firstBlockLength = 0; firstBlockLength <= npages; firstBlockLength++) {
    y[firstBlockLength] = y[firstBlockLength] / static_cast<double>(x.size(0));
  }
}

void mean(const ::coder::array<creal_T, 2U> &x, ::coder::array<creal_T, 2U> &y)
{
  double bsum_im;
  double bsum_re;
  int hi;
  int xblockoffset;
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    y.set_size(1, x.size(1));
    xblockoffset = x.size(1);
    for (hi = 0; hi < xblockoffset; hi++) {
      y[hi].re = 0.0;
      y[hi].im = 0.0;
    }
  } else {
    int firstBlockLength;
    int lastBlockLength;
    int nblocks;
    int npages;
    npages = x.size(1);
    y.set_size(1, x.size(1));
    if (x.size(0) <= 1024) {
      firstBlockLength = x.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x.size(0) >> 10;
      lastBlockLength = x.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (int xi{0}; xi < npages; xi++) {
      int xpageoffset;
      xpageoffset = xi * x.size(0);
      y[xi] = x[xpageoffset];
      for (int k{2}; k <= firstBlockLength; k++) {
        hi = (xpageoffset + k) - 1;
        y[xi].re = y[xi].re + x[hi].re;
        y[xi].im = y[xi].im + x[hi].im;
      }
      for (int ib{2}; ib <= nblocks; ib++) {
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        bsum_re = x[xblockoffset].re;
        bsum_im = x[xblockoffset].im;
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (int k{2}; k <= hi; k++) {
          int bsum_re_tmp;
          bsum_re_tmp = (xblockoffset + k) - 1;
          bsum_re += x[bsum_re_tmp].re;
          bsum_im += x[bsum_re_tmp].im;
        }
        y[xi].re = y[xi].re + bsum_re;
        y[xi].im = y[xi].im + bsum_im;
      }
    }
  }
  y.set_size(1, y.size(1));
  bsum_re = x.size(0);
  xblockoffset = y.size(1) - 1;
  for (hi = 0; hi <= xblockoffset; hi++) {
    double ai;
    double re;
    bsum_im = y[hi].re;
    ai = y[hi].im;
    if (ai == 0.0) {
      re = bsum_im / bsum_re;
      bsum_im = 0.0;
    } else if (bsum_im == 0.0) {
      re = 0.0;
      bsum_im = ai / bsum_re;
    } else {
      re = bsum_im / bsum_re;
      bsum_im = ai / bsum_re;
    }
    y[hi].re = re;
    y[hi].im = bsum_im;
  }
}

} // namespace coder

// End of code generation (mean.cpp)
