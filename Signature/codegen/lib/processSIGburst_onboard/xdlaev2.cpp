//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdlaev2.cpp
//
// Code generation for function 'xdlaev2'
//

// Include files
#include "xdlaev2.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
double xdlaev2(double a, double b, double c, double &rt2, double *cs1,
               double &sn1)
{
  double ab;
  double acmn;
  double acmx;
  double adf;
  double df;
  double rt1;
  double sm;
  double tb;
  int sgn1;
  int sgn2;
  sm = a + c;
  df = a - c;
  adf = std::abs(df);
  tb = b + b;
  ab = std::abs(tb);
  if (std::abs(a) > std::abs(c)) {
    acmx = a;
    acmn = c;
  } else {
    acmx = c;
    acmn = a;
  }
  if (adf > ab) {
    double b_a;
    b_a = ab / adf;
    adf *= std::sqrt(b_a * b_a + 1.0);
  } else if (adf < ab) {
    double b_a;
    b_a = adf / ab;
    adf = ab * std::sqrt(b_a * b_a + 1.0);
  } else {
    adf = ab * 1.4142135623730951;
  }
  if (sm < 0.0) {
    rt1 = 0.5 * (sm - adf);
    sgn1 = -1;
    rt2 = acmx / rt1 * acmn - b / rt1 * b;
  } else if (sm > 0.0) {
    rt1 = 0.5 * (sm + adf);
    sgn1 = 1;
    rt2 = acmx / rt1 * acmn - b / rt1 * b;
  } else {
    rt1 = 0.5 * adf;
    rt2 = -0.5 * adf;
    sgn1 = 1;
  }
  if (df >= 0.0) {
    adf += df;
    sgn2 = 1;
  } else {
    adf = df - adf;
    sgn2 = -1;
  }
  if (std::abs(adf) > ab) {
    adf = -tb / adf;
    sn1 = 1.0 / std::sqrt(adf * adf + 1.0);
    *cs1 = adf * sn1;
  } else if (ab == 0.0) {
    *cs1 = 1.0;
    sn1 = 0.0;
  } else {
    adf = -adf / tb;
    *cs1 = 1.0 / std::sqrt(adf * adf + 1.0);
    sn1 = adf * *cs1;
  }
  if (sgn1 == sgn2) {
    adf = *cs1;
    *cs1 = -sn1;
    sn1 = adf;
  }
  return rt1;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdlaev2.cpp)
