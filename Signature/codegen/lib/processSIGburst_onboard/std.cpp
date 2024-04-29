//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// std.cpp
//
// Code generation for function 'std'
//

// Include files
#include "std.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void b_std(const ::coder::array<double, 3U> &x, double y[16384])
{
  array<double, 1U> absdiff;
  array<double, 1U> xv;
  int loop_ub;
  int n;
  loop_ub = x.size(2);
  n = x.size(2);
  for (int j{0}; j < 16384; j++) {
    int nn;
    int nnans;
    xv.set_size(x.size(2));
    for (int k{0}; k < loop_ub; k++) {
      xv[k] = x[j + (k << 14)];
    }
    nnans = 0;
    for (int k{0}; k < n; k++) {
      if (std::isnan(xv[k])) {
        nnans++;
      } else {
        xv[k - nnans] = xv[k];
      }
    }
    nn = x.size(2) - nnans;
    if (nn == 0) {
      y[j] = rtNaN;
    } else if (nn == 1) {
      if ((!std::isinf(xv[0])) && (!std::isnan(xv[0]))) {
        y[j] = 0.0;
      } else {
        y[j] = rtNaN;
      }
    } else {
      double bsum;
      double xbar;
      if ((xv.size(0) == 0) || (nn == 0)) {
        xbar = 0.0;
      } else {
        int lastBlockLength;
        int nblocks;
        if (nn <= 1024) {
          nnans = nn;
          lastBlockLength = 0;
          nblocks = 1;
        } else {
          nnans = 1024;
          nblocks = nn >> 10;
          lastBlockLength = nn - (nblocks << 10);
          if (lastBlockLength > 0) {
            nblocks++;
          } else {
            lastBlockLength = 1024;
          }
        }
        xbar = xv[0];
        for (int k{2}; k <= nnans; k++) {
          xbar += xv[k - 1];
        }
        for (int ib{2}; ib <= nblocks; ib++) {
          int hi;
          nnans = (ib - 1) << 10;
          bsum = xv[nnans];
          if (ib == nblocks) {
            hi = lastBlockLength;
          } else {
            hi = 1024;
          }
          for (int k{2}; k <= hi; k++) {
            bsum += xv[(nnans + k) - 1];
          }
          xbar += bsum;
        }
      }
      xbar /= static_cast<double>(nn);
      absdiff.set_size(xv.size(0));
      for (int k{0}; k < nn; k++) {
        absdiff[k] = std::abs(xv[k] - xbar);
      }
      xbar = 0.0;
      if (nn >= 1) {
        if (nn == 1) {
          xbar = absdiff[0];
        } else {
          bsum = 3.3121686421112381E-170;
          for (int k{0}; k < nn; k++) {
            if (absdiff[k] > bsum) {
              double t;
              t = bsum / absdiff[k];
              xbar = xbar * t * t + 1.0;
              bsum = absdiff[k];
            } else {
              double t;
              t = absdiff[k] / bsum;
              xbar += t * t;
            }
          }
          xbar = bsum * std::sqrt(xbar);
        }
      }
      y[j] = xbar / std::sqrt(static_cast<double>(nn - 1));
    }
  }
}

} // namespace coder

// End of code generation (std.cpp)
