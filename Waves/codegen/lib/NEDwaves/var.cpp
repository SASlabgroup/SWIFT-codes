//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// var.cpp
//
// Code generation for function 'var'
//

// Include files
#include "var.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void var(const ::coder::array<double, 2U> &x, ::coder::array<double, 2U> &y)
{
  array<double, 1U> xv;
  int firstBlockLength;
  int hi;
  int loop_ub;
  int n;
  int npages;
  int nx;
  int outsize_idx_0;
  y.set_size(1, x.size(1));
  firstBlockLength = x.size(1);
  for (hi = 0; hi < firstBlockLength; hi++) {
    y[hi] = 0.0;
  }
  nx = x.size(0);
  npages = x.size(1);
  if (x.size(1) - 1 >= 0) {
    outsize_idx_0 = x.size(0);
    loop_ub = x.size(0);
    n = x.size(0);
  }
  for (int p{0}; p < npages; p++) {
    firstBlockLength = p * nx;
    xv.set_size(outsize_idx_0);
    for (hi = 0; hi < loop_ub; hi++) {
      xv[hi] = 0.0;
    }
    for (int k{0}; k < nx; k++) {
      xv[k] = x[firstBlockLength + k];
    }
    if (x.size(0) == 0) {
      y[p] = rtNaN;
    } else if (x.size(0) == 1) {
      if ((!std::isinf(xv[0])) && (!std::isnan(xv[0]))) {
        y[p] = 0.0;
      } else {
        y[p] = rtNaN;
      }
    } else {
      double bsum;
      double xbar;
      if (xv.size(0) == 0) {
        xbar = 0.0;
      } else {
        int lastBlockLength;
        int nblocks;
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
        xbar = xv[0];
        for (int k{2}; k <= firstBlockLength; k++) {
          xbar += xv[k - 1];
        }
        for (int ib{2}; ib <= nblocks; ib++) {
          firstBlockLength = (ib - 1) << 10;
          bsum = xv[firstBlockLength];
          if (ib == nblocks) {
            hi = lastBlockLength;
          } else {
            hi = 1024;
          }
          for (int k{2}; k <= hi; k++) {
            bsum += xv[(firstBlockLength + k) - 1];
          }
          xbar += bsum;
        }
      }
      xbar /= static_cast<double>(x.size(0));
      bsum = 0.0;
      for (int k{0}; k < n; k++) {
        double t;
        t = xv[k] - xbar;
        bsum += t * t;
      }
      y[p] = bsum / (static_cast<double>(x.size(0)) - 1.0);
    }
  }
}

} // namespace coder

// End of code generation (var.cpp)
