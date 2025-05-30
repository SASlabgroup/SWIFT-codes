//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sortLE.cpp
//
// Code generation for function 'sortLE'
//

// Include files
#include "sortLE.h"
#include "eof_rtwutil.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "rt_defines.h"
#include <cmath>

// Function Declarations
static double rt_atan2d_snf(double u0, double u1);

// Function Definitions
static double rt_atan2d_snf(double u0, double u1)
{
  double y;
  if (std::isnan(u0) || std::isnan(u1)) {
    y = rtNaN;
  } else if (std::isinf(u0) && std::isinf(u1)) {
    int b_u0;
    int b_u1;
    if (u0 > 0.0) {
      b_u0 = 1;
    } else {
      b_u0 = -1;
    }
    if (u1 > 0.0) {
      b_u1 = 1;
    } else {
      b_u1 = -1;
    }
    y = std::atan2(static_cast<double>(b_u0), static_cast<double>(b_u1));
  } else if (u1 == 0.0) {
    if (u0 > 0.0) {
      y = RT_PI / 2.0;
    } else if (u0 < 0.0) {
      y = -(RT_PI / 2.0);
    } else {
      y = 0.0;
    }
  } else {
    y = std::atan2(u0, u1);
  }
  return y;
}

namespace coder {
namespace internal {
bool sortLE(const ::coder::array<creal_T, 1U> &v, int idx1, int idx2)
{
  bool p;
  if (std::isnan(v[idx2 - 1].re) || std::isnan(v[idx2 - 1].im)) {
    p = (std::isnan(v[idx1 - 1].re) || std::isnan(v[idx1 - 1].im));
  } else if (std::isnan(v[idx1 - 1].re) || std::isnan(v[idx1 - 1].im)) {
    p = true;
  } else {
    double bi;
    double x;
    bool SCALEA;
    bool SCALEB;
    if ((std::abs(v[idx1 - 1].re) > 8.9884656743115785E+307) ||
        (std::abs(v[idx1 - 1].im) > 8.9884656743115785E+307)) {
      SCALEA = true;
    } else {
      SCALEA = false;
    }
    if ((std::abs(v[idx2 - 1].re) > 8.9884656743115785E+307) ||
        (std::abs(v[idx2 - 1].im) > 8.9884656743115785E+307)) {
      SCALEB = true;
    } else {
      SCALEB = false;
    }
    if (SCALEA || SCALEB) {
      x = rt_hypotd_snf(v[idx1 - 1].re / 2.0, v[idx1 - 1].im / 2.0);
      bi = rt_hypotd_snf(v[idx2 - 1].re / 2.0, v[idx2 - 1].im / 2.0);
    } else {
      x = rt_hypotd_snf(v[idx1 - 1].re, v[idx1 - 1].im);
      bi = rt_hypotd_snf(v[idx2 - 1].re, v[idx2 - 1].im);
    }
    if (x == bi) {
      x = rt_atan2d_snf(v[idx1 - 1].im, v[idx1 - 1].re);
      bi = rt_atan2d_snf(v[idx2 - 1].im, v[idx2 - 1].re);
      if (x == bi) {
        double ai;
        double ar;
        double br;
        ar = v[idx1 - 1].re;
        ai = v[idx1 - 1].im;
        br = v[idx2 - 1].re;
        bi = v[idx2 - 1].im;
        if (ar != br) {
          if (x >= 0.0) {
            x = br;
            bi = ar;
          } else {
            x = ar;
            bi = br;
          }
        } else if (ar < 0.0) {
          x = bi;
          bi = ai;
        } else {
          x = ai;
        }
        if (x == bi) {
          x = 0.0;
          bi = 0.0;
        }
      }
    }
    p = (x >= bi);
  }
  return p;
}

} // namespace internal
} // namespace coder

// End of code generation (sortLE.cpp)
