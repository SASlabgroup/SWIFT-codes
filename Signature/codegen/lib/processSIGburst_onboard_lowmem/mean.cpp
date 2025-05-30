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
#include "div.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "rt_nonfinite.h"

// Function Definitions
namespace coder {
double b_mean(const ::coder::array<double, 2U> &x)
{
  double y;
  int counts;
  if (x.size(1) == 0) {
    y = 0.0;
    counts = 0;
  } else {
    double bsum;
    int firstBlockLength;
    int lastBlockLength;
    int nblocks;
    if (x.size(1) <= 1024) {
      firstBlockLength = x.size(1);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(x.size(1)) >> 10);
      lastBlockLength = x.size(1) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    if (rtIsNaN(x[0])) {
      y = 0.0;
      counts = 0;
    } else {
      y = x[0];
      counts = 1;
    }
    for (int k = 2; k <= firstBlockLength; k++) {
      bsum = x[k - 1];
      if (!rtIsNaN(bsum)) {
        y += bsum;
        counts++;
      }
    }
    for (int ib = 2; ib <= nblocks; ib++) {
      int hi;
      firstBlockLength = (ib - 1) << 10;
      bsum = x[firstBlockLength];
      if (rtIsNaN(bsum)) {
        bsum = 0.0;
      } else {
        counts++;
      }
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (int k = 2; k <= hi; k++) {
        int xoffset;
        xoffset = (firstBlockLength + k) - 1;
        if (!rtIsNaN(x[xoffset])) {
          bsum += x[xoffset];
          counts++;
        }
      }
      y += bsum;
    }
  }
  y /= static_cast<double>(counts);
  return y;
}

void mean(const ::coder::array<double, 2U> &x, ::coder::array<double, 2U> &y)
{
  array<int, 2U> counts;
  int firstBlockLength;
  int npages;
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    y.set_size(1, x.size(1));
    npages = x.size(1);
    counts.set_size(1, x.size(1));
    for (firstBlockLength = 0; firstBlockLength < npages; firstBlockLength++) {
      y[firstBlockLength] = 0.0;
      counts[firstBlockLength] = 0;
    }
  } else {
    int lastBlockLength;
    int nblocks;
    npages = x.size(1);
    y.set_size(1, x.size(1));
    counts.set_size(1, x.size(1));
    if (x.size(0) <= 1024) {
      firstBlockLength = x.size(0);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(x.size(0)) >> 10);
      lastBlockLength = x.size(0) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (int xi = 0; xi < npages; xi++) {
      int xoffset;
      int xpageoffset;
      xpageoffset = xi * x.size(0);
      if (rtIsNaN(x[xpageoffset])) {
        y[xi] = 0.0;
        counts[xi] = 0;
      } else {
        y[xi] = x[xpageoffset];
        counts[xi] = 1;
      }
      for (int k = 2; k <= firstBlockLength; k++) {
        xoffset = (xpageoffset + k) - 1;
        if (!rtIsNaN(x[xoffset])) {
          y[xi] = y[xi] + x[xoffset];
          counts[xi] = counts[xi] + 1;
        }
      }
      for (int ib = 2; ib <= nblocks; ib++) {
        double bsum;
        int hi;
        int xblockoffset;
        xblockoffset = xpageoffset + ((ib - 1) << 10);
        if (rtIsNaN(x[xblockoffset])) {
          bsum = 0.0;
        } else {
          bsum = x[xblockoffset];
          counts[xi] = counts[xi] + 1;
        }
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (int k = 2; k <= hi; k++) {
          xoffset = (xblockoffset + k) - 1;
          if (!rtIsNaN(x[xoffset])) {
            bsum += x[xoffset];
            counts[xi] = counts[xi] + 1;
          }
        }
        y[xi] = y[xi] + bsum;
      }
    }
  }
  if (y.size(1) == counts.size(1)) {
    npages = y.size(1) - 1;
    y.set_size(1, y.size(1));
    for (firstBlockLength = 0; firstBlockLength <= npages; firstBlockLength++) {
      y[firstBlockLength] =
          y[firstBlockLength] / static_cast<double>(counts[firstBlockLength]);
    }
  } else {
    binary_expand_op(y, counts);
  }
}

double mean(const ::coder::array<double, 2U> &x)
{
  double y;
  if (x.size(1) == 0) {
    y = 0.0;
  } else {
    int firstBlockLength;
    int lastBlockLength;
    int nblocks;
    if (x.size(1) <= 1024) {
      firstBlockLength = x.size(1);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(x.size(1)) >> 10);
      lastBlockLength = x.size(1) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    y = x[0];
    for (int k = 2; k <= firstBlockLength; k++) {
      y += x[k - 1];
    }
    for (int ib = 2; ib <= nblocks; ib++) {
      double bsum;
      int hi;
      firstBlockLength = (ib - 1) << 10;
      bsum = x[firstBlockLength];
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (int k = 2; k <= hi; k++) {
        bsum += x[(firstBlockLength + k) - 1];
      }
      y += bsum;
    }
  }
  y /= static_cast<double>(x.size(1));
  return y;
}

void mean(const ::coder::array<double, 2U> &x, ::coder::array<double, 1U> &y)
{
  array<double, 1U> bsum;
  array<int, 1U> counts;
  int firstBlockLength;
  int xblockoffset;
  if ((x.size(0) == 0) || (x.size(1) == 0)) {
    y.set_size(x.size(0));
    firstBlockLength = x.size(0);
    counts.set_size(x.size(0));
    for (xblockoffset = 0; xblockoffset < firstBlockLength; xblockoffset++) {
      y[xblockoffset] = 0.0;
      counts[xblockoffset] = 0;
    }
  } else {
    int bvstride;
    int ix;
    int lastBlockLength;
    int nblocks;
    int vstride;
    int xoffset;
    vstride = x.size(0) - 1;
    bvstride = x.size(0) << 10;
    y.set_size(x.size(0));
    counts.set_size(x.size(0));
    bsum.set_size(x.size(0));
    if (x.size(1) <= 1024) {
      firstBlockLength = x.size(1);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(x.size(1)) >> 10);
      lastBlockLength = x.size(1) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (int xj = 0; xj <= vstride; xj++) {
      if (rtIsNaN(x[xj])) {
        y[xj] = 0.0;
        counts[xj] = 0;
      } else {
        y[xj] = x[xj];
        counts[xj] = 1;
      }
      bsum[xj] = 0.0;
    }
    for (int k = 2; k <= firstBlockLength; k++) {
      xoffset = (k - 1) * (vstride + 1);
      for (int xj = 0; xj <= vstride; xj++) {
        ix = xoffset + xj;
        if (!rtIsNaN(x[ix])) {
          y[xj] = y[xj] + x[ix];
          counts[xj] = counts[xj] + 1;
        }
      }
    }
    for (int ib = 2; ib <= nblocks; ib++) {
      xblockoffset = (ib - 1) * bvstride;
      for (int xj = 0; xj <= vstride; xj++) {
        ix = xblockoffset + xj;
        if (rtIsNaN(x[ix])) {
          bsum[xj] = 0.0;
        } else {
          bsum[xj] = x[ix];
          counts[xj] = counts[xj] + 1;
        }
      }
      if (ib == nblocks) {
        firstBlockLength = lastBlockLength;
      } else {
        firstBlockLength = 1024;
      }
      for (int k = 2; k <= firstBlockLength; k++) {
        xoffset = xblockoffset + (k - 1) * (vstride + 1);
        for (int xj = 0; xj <= vstride; xj++) {
          ix = xoffset + xj;
          if (!rtIsNaN(x[ix])) {
            bsum[xj] = bsum[xj] + x[ix];
            counts[xj] = counts[xj] + 1;
          }
        }
      }
      for (int xj = 0; xj <= vstride; xj++) {
        y[xj] = y[xj] + bsum[xj];
      }
    }
  }
  if (y.size(0) == counts.size(0)) {
    firstBlockLength = y.size(0);
    for (xblockoffset = 0; xblockoffset < firstBlockLength; xblockoffset++) {
      y[xblockoffset] =
          y[xblockoffset] / static_cast<double>(counts[xblockoffset]);
    }
  } else {
    binary_expand_op(y, counts);
  }
}

} // namespace coder

// End of code generation (mean.cpp)
