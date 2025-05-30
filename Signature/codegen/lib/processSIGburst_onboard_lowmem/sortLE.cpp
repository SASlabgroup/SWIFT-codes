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
#include "processSIGburst_onboard_lowmem_rtwutil.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Declarations
static double rt_atan2d_snf(double u0, double u1);

// Function Definitions
static double rt_atan2d_snf(double u0, double u1)
{
  double y;
  if (rtIsNaN(u0) || rtIsNaN(u1)) {
    y = rtNaN;
  } else if (rtIsInf(u0) && rtIsInf(u1)) {
    int i;
    int i1;
    if (u0 > 0.0) {
      i = 1;
    } else {
      i = -1;
    }
    if (u1 > 0.0) {
      i1 = 1;
    } else {
      i1 = -1;
    }
    y = std::atan2(static_cast<double>(i), static_cast<double>(i1));
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
  if (rtIsNaN(v[idx2 - 1].re) || rtIsNaN(v[idx2 - 1].im)) {
    p = (rtIsNaN(v[idx1 - 1].re) || rtIsNaN(v[idx1 - 1].im));
  } else if (rtIsNaN(v[idx1 - 1].re) || rtIsNaN(v[idx1 - 1].im)) {
    p = true;
  } else {
    double x;
    double y;
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
      y = rt_hypotd_snf(v[idx2 - 1].re / 2.0, v[idx2 - 1].im / 2.0);
    } else {
      x = rt_hypotd_snf(v[idx1 - 1].re, v[idx1 - 1].im);
      y = rt_hypotd_snf(v[idx2 - 1].re, v[idx2 - 1].im);
    }
    if (x == y) {
      double b_x_tmp;
      double b_y_tmp;
      double x_tmp;
      double y_tmp;
      x_tmp = v[idx1 - 1].re;
      b_x_tmp = v[idx1 - 1].im;
      x = rt_atan2d_snf(b_x_tmp, x_tmp);
      y_tmp = v[idx2 - 1].re;
      b_y_tmp = v[idx2 - 1].im;
      y = rt_atan2d_snf(b_y_tmp, y_tmp);
      if (x == y) {
        if (x_tmp != y_tmp) {
          if (x >= 0.0) {
            x = y_tmp;
            b_y_tmp = x_tmp;
          } else {
            x = x_tmp;
            b_y_tmp = y_tmp;
          }
        } else if (x_tmp < 0.0) {
          x = b_y_tmp;
          b_y_tmp = b_x_tmp;
        } else {
          x = b_x_tmp;
        }
        y = b_y_tmp;
        if (x == b_y_tmp) {
          x = 0.0;
          y = 0.0;
        }
      }
    }
    p = (x >= y);
  }
  return p;
}

} // namespace internal
} // namespace coder

// End of code generation (sortLE.cpp)
