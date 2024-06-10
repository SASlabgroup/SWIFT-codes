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
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
double b_std(const ::coder::array<double, 2U> &x)
{
  array<double, 1U> absdiff;
  array<double, 1U> v;
  double y;
  int hi;
  int nn;
  int nnans;
  nn = x.size(1);
  v.set_size(x.size(1));
  nnans = x.size(1);
  for (hi = 0; hi < nnans; hi++) {
    v[hi] = x[hi];
  }
  nnans = 0;
  for (int k = 0; k < nn; k++) {
    if (rtIsNaN(v[k])) {
      nnans++;
    } else {
      v[k - nnans] = v[k];
    }
  }
  nn = x.size(1) - nnans;
  if (nn == 0) {
    y = rtNaN;
  } else if (nn == 1) {
    if ((!rtIsInf(v[0])) && (!rtIsNaN(v[0]))) {
      y = 0.0;
    } else {
      y = rtNaN;
    }
  } else {
    double bsum;
    double xbar;
    if ((v.size(0) == 0) || (nn == 0)) {
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
      xbar = v[0];
      for (int k = 2; k <= nnans; k++) {
        xbar += v[k - 1];
      }
      for (int ib = 2; ib <= nblocks; ib++) {
        nnans = (ib - 1) << 10;
        bsum = v[nnans];
        if (ib == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }
        for (int k = 2; k <= hi; k++) {
          bsum += v[(nnans + k) - 1];
        }
        xbar += bsum;
      }
    }
    xbar /= static_cast<double>(nn);
    absdiff.set_size(v.size(0));
    for (int k = 0; k < nn; k++) {
      absdiff[k] = std::abs(v[k] - xbar);
    }
    y = 0.0;
    if (nn >= 1) {
      if (nn == 1) {
        y = absdiff[0];
      } else {
        xbar = 3.3121686421112381E-170;
        for (int k = 0; k < nn; k++) {
          if (absdiff[k] > xbar) {
            bsum = xbar / absdiff[k];
            y = y * bsum * bsum + 1.0;
            xbar = absdiff[k];
          } else {
            bsum = absdiff[k] / xbar;
            y += bsum * bsum;
          }
        }
        y = xbar * std::sqrt(y);
      }
    }
    y /= std::sqrt(static_cast<double>(nn) - 1.0);
  }
  return y;
}

} // namespace coder

// End of code generation (std.cpp)
