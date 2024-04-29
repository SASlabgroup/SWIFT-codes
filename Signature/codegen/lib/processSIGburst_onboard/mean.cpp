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
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>
#include <cstring>

// Function Definitions
namespace coder {
void mean(const ::coder::array<double, 2U> &x, double y[128])
{
  int counts[128];
  int firstBlockLength;
  if (x.size(1) == 0) {
    std::memset(&y[0], 0, 128U * sizeof(double));
    std::memset(&counts[0], 0, 128U * sizeof(int));
  } else {
    int ix;
    int lastBlockLength;
    int nblocks;
    int xoffset;
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
    for (int xj{0}; xj < 128; xj++) {
      if (std::isnan(x[xj])) {
        y[xj] = 0.0;
        counts[xj] = 0;
      } else {
        y[xj] = x[xj];
        counts[xj] = 1;
      }
    }
    for (int k{2}; k <= firstBlockLength; k++) {
      xoffset = (k - 1) << 7;
      for (int xj{0}; xj < 128; xj++) {
        ix = xoffset + xj;
        if (!std::isnan(x[ix])) {
          y[xj] += x[ix];
          counts[xj]++;
        }
      }
    }
    for (int ib{2}; ib <= nblocks; ib++) {
      double bsum[128];
      int hi;
      firstBlockLength = (ib - 1) << 17;
      for (int xj{0}; xj < 128; xj++) {
        ix = firstBlockLength + xj;
        if (std::isnan(x[ix])) {
          bsum[xj] = 0.0;
        } else {
          bsum[xj] = x[ix];
          counts[xj]++;
        }
      }
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (int k{2}; k <= hi; k++) {
        xoffset = firstBlockLength + ((k - 1) << 7);
        for (int xj{0}; xj < 128; xj++) {
          ix = xoffset + xj;
          if (!std::isnan(x[ix])) {
            bsum[xj] += x[ix];
            counts[xj]++;
          }
        }
      }
      for (int xj{0}; xj < 128; xj++) {
        y[xj] += bsum[xj];
      }
    }
  }
  for (firstBlockLength = 0; firstBlockLength < 128; firstBlockLength++) {
    y[firstBlockLength] /= static_cast<double>(counts[firstBlockLength]);
  }
}

void mean(const ::coder::array<double, 3U> &x, double y[16384])
{
  static double bsum[16384];
  static int counts[16384];
  int firstBlockLength;
  if (x.size(2) == 0) {
    std::memset(&y[0], 0, 16384U * sizeof(double));
    std::memset(&counts[0], 0, 16384U * sizeof(int));
  } else {
    int ix;
    int lastBlockLength;
    int nblocks;
    int xoffset;
    if (x.size(2) <= 1024) {
      firstBlockLength = x.size(2);
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = static_cast<int>(static_cast<unsigned int>(x.size(2)) >> 10);
      lastBlockLength = x.size(2) - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }
    for (int xj{0}; xj < 16384; xj++) {
      if (std::isnan(x[xj])) {
        y[xj] = 0.0;
        counts[xj] = 0;
      } else {
        y[xj] = x[xj];
        counts[xj] = 1;
      }
    }
    for (int k{2}; k <= firstBlockLength; k++) {
      xoffset = (k - 1) << 14;
      for (int xj{0}; xj < 16384; xj++) {
        ix = xoffset + xj;
        if (!std::isnan(x[ix])) {
          y[xj] += x[ix];
          counts[xj]++;
        }
      }
    }
    for (int ib{2}; ib <= nblocks; ib++) {
      int hi;
      firstBlockLength = (ib - 1) << 24;
      for (int xj{0}; xj < 16384; xj++) {
        ix = firstBlockLength + xj;
        if (std::isnan(x[ix])) {
          bsum[xj] = 0.0;
        } else {
          bsum[xj] = x[ix];
          counts[xj]++;
        }
      }
      if (ib == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }
      for (int k{2}; k <= hi; k++) {
        xoffset = firstBlockLength + ((k - 1) << 14);
        for (int xj{0}; xj < 16384; xj++) {
          ix = xoffset + xj;
          if (!std::isnan(x[ix])) {
            bsum[xj] += x[ix];
            counts[xj]++;
          }
        }
      }
      for (int xj{0}; xj < 16384; xj++) {
        y[xj] += bsum[xj];
      }
    }
  }
  for (firstBlockLength = 0; firstBlockLength < 16384; firstBlockLength++) {
    y[firstBlockLength] /= static_cast<double>(counts[firstBlockLength]);
  }
}

} // namespace coder

// End of code generation (mean.cpp)
