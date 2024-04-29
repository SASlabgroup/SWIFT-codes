//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mpower.cpp
//
// Code generation for function 'mpower'
//

// Include files
#include "mpower.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
void mpower(const double a[4], double c[4])
{
  if (std::abs(a[1]) > std::abs(a[0])) {
    double r;
    double t;
    r = a[0] / a[1];
    t = 1.0 / (r * a[3] - a[2]);
    c[0] = a[3] / a[1] * t;
    c[1] = -t;
    c[2] = -a[2] / a[1] * t;
    c[3] = r * t;
  } else {
    double r;
    double t;
    r = a[1] / a[0];
    t = 1.0 / (a[3] - r * a[2]);
    c[0] = a[3] / a[0] * t;
    c[1] = -r * t;
    c[2] = -a[2] / a[0] * t;
    c[3] = t;
  }
}

} // namespace coder

// End of code generation (mpower.cpp)
