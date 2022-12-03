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
float b_std(const ::coder::array<float, 1U> &x)
{
  array<float, 1U> absdiff;
  float y;
  int kend;
  kend = x.size(0);
  if (x.size(0) == 0) {
    y = rtNaNF;
  } else if (x.size(0) == 1) {
    if ((!std::isinf(x[0])) && (!std::isnan(x[0]))) {
      y = 0.0F;
    } else {
      y = rtNaNF;
    }
  } else {
    float xbar;
    xbar = blockedSummation(x, x.size(0)) / static_cast<float>(x.size(0));
    absdiff.set_size(x.size(0));
    for (int k{0}; k < kend; k++) {
      absdiff[k] = std::abs(x[k] - xbar);
    }
    y = 0.0F;
    xbar = 1.29246971E-26F;
    kend = x.size(0);
    for (int k{0}; k < kend; k++) {
      if (absdiff[k] > xbar) {
        float t;
        t = xbar / absdiff[k];
        y = y * t * t + 1.0F;
        xbar = absdiff[k];
      } else {
        float t;
        t = absdiff[k] / xbar;
        y += t * t;
      }
    }
    y = xbar * std::sqrt(y) / std::sqrt(static_cast<float>(x.size(0) - 1));
  }
  return y;
}

} // namespace coder

// End of code generation (std.cpp)
