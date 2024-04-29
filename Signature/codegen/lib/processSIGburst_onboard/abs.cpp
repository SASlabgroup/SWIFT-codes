//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// abs.cpp
//
// Code generation for function 'abs'
//

// Include files
#include "abs.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void b_abs(const ::coder::array<double, 2U> &x, ::coder::array<double, 2U> &y)
{
  int nx;
  nx = x.size(0) * x.size(1);
  y.set_size(x.size(0), x.size(1));
  for (int k{0}; k < nx; k++) {
    y[k] = std::abs(x[k]);
  }
}

} // namespace coder

// End of code generation (abs.cpp)
