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
#include "blockedSummation.h"
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
    nnans = x.size(2) - nnans;
    if (nnans == 0) {
      y[j] = rtNaN;
    } else if (nnans == 1) {
      if ((!std::isinf(xv[0])) && (!std::isnan(xv[0]))) {
        y[j] = 0.0;
      } else {
        y[j] = rtNaN;
      }
    } else {
      double xbar;
      xbar = blockedSummation(xv, nnans) / static_cast<double>(nnans);
      absdiff.set_size(xv.size(0));
      for (int k{0}; k < nnans; k++) {
        absdiff[k] = std::abs(xv[k] - xbar);
      }
      xbar = 0.0;
      if (nnans >= 1) {
        if (nnans == 1) {
          xbar = absdiff[0];
        } else {
          double scale;
          scale = 3.3121686421112381E-170;
          for (int k{0}; k < nnans; k++) {
            if (absdiff[k] > scale) {
              double t;
              t = scale / absdiff[k];
              xbar = xbar * t * t + 1.0;
              scale = absdiff[k];
            } else {
              double t;
              t = absdiff[k] / scale;
              xbar += t * t;
            }
          }
          xbar = scale * std::sqrt(xbar);
        }
      }
      y[j] = xbar / std::sqrt(static_cast<double>(nnans - 1));
    }
  }
}

} // namespace coder

// End of code generation (std.cpp)
