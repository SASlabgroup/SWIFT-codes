//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xnrm2.cpp
//
// Code generation for function 'xnrm2'
//

// Include files
#include "xnrm2.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace blas {
float xnrm2(int n, const ::coder::array<float, 2U> &x, int ix0)
{
  float y;
  y = 0.0F;
  if (n >= 1) {
    if (n == 1) {
      y = std::abs(x[ix0 - 1]);
    } else {
      float scale;
      int kend;
      scale = 1.29246971E-26F;
      kend = (ix0 + n) - 1;
      for (int k{ix0}; k <= kend; k++) {
        float absxk;
        absxk = std::abs(x[k - 1]);
        if (absxk > scale) {
          float t;
          t = scale / absxk;
          y = y * t * t + 1.0F;
          scale = absxk;
        } else {
          float t;
          t = absxk / scale;
          y += t * t;
        }
      }
      y = scale * std::sqrt(y);
    }
  }
  return y;
}

double xnrm2(int n, const ::coder::array<double, 2U> &x, int ix0)
{
  double scale;
  double y;
  int kend;
  y = 0.0;
  scale = 3.3121686421112381E-170;
  kend = (ix0 + n) - 1;
  for (int k{ix0}; k <= kend; k++) {
    double absxk;
    absxk = std::abs(x[k - 1]);
    if (absxk > scale) {
      double t;
      t = scale / absxk;
      y = y * t * t + 1.0;
      scale = absxk;
    } else {
      double t;
      t = absxk / scale;
      y += t * t;
    }
  }
  return scale * std::sqrt(y);
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (xnrm2.cpp)
