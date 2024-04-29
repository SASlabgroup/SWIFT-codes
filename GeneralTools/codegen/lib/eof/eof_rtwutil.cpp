//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eof_rtwutil.cpp
//
// Code generation for function 'eof_rtwutil'
//

// Include files
#include "eof_rtwutil.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
double rt_hypotd_snf(double u0, double u1)
{
  double a;
  double y;
  a = std::abs(u0);
  y = std::abs(u1);
  if (a < y) {
    a /= y;
    y *= std::sqrt(a * a + 1.0);
  } else if (a > y) {
    y /= a;
    y = a * std::sqrt(y * y + 1.0);
  } else if (!std::isnan(y)) {
    y = a * 1.4142135623730951;
  }
  return y;
}

// End of code generation (eof_rtwutil.cpp)
