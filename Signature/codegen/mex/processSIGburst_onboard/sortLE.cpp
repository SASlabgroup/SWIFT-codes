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
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include "mwmathutil.h"

// Function Definitions
namespace coder {
namespace internal {
boolean_T sortLE(const ::coder::array<creal_T, 1U> &v, int32_T idx1,
                 int32_T idx2)
{
  boolean_T p;
  if (muDoubleScalarIsNaN(v[idx2 - 1].re) ||
      muDoubleScalarIsNaN(v[idx2 - 1].im)) {
    p = (muDoubleScalarIsNaN(v[idx1 - 1].re) ||
         muDoubleScalarIsNaN(v[idx1 - 1].im));
  } else if (muDoubleScalarIsNaN(v[idx1 - 1].re) ||
             muDoubleScalarIsNaN(v[idx1 - 1].im)) {
    p = true;
  } else {
    real_T x;
    real_T y;
    boolean_T SCALEA;
    boolean_T SCALEB;
    if ((muDoubleScalarAbs(v[idx1 - 1].re) > 8.9884656743115785E+307) ||
        (muDoubleScalarAbs(v[idx1 - 1].im) > 8.9884656743115785E+307)) {
      SCALEA = true;
    } else {
      SCALEA = false;
    }
    if ((muDoubleScalarAbs(v[idx2 - 1].re) > 8.9884656743115785E+307) ||
        (muDoubleScalarAbs(v[idx2 - 1].im) > 8.9884656743115785E+307)) {
      SCALEB = true;
    } else {
      SCALEB = false;
    }
    if (SCALEA || SCALEB) {
      x = muDoubleScalarHypot(v[idx1 - 1].re / 2.0, v[idx1 - 1].im / 2.0);
      y = muDoubleScalarHypot(v[idx2 - 1].re / 2.0, v[idx2 - 1].im / 2.0);
    } else {
      x = muDoubleScalarHypot(v[idx1 - 1].re, v[idx1 - 1].im);
      y = muDoubleScalarHypot(v[idx2 - 1].re, v[idx2 - 1].im);
    }
    if (x == y) {
      real_T b_x_tmp;
      real_T b_y_tmp;
      real_T x_tmp;
      real_T y_tmp;
      x_tmp = v[idx1 - 1].re;
      b_x_tmp = v[idx1 - 1].im;
      x = muDoubleScalarAtan2(b_x_tmp, x_tmp);
      y_tmp = v[idx2 - 1].re;
      b_y_tmp = v[idx2 - 1].im;
      y = muDoubleScalarAtan2(b_y_tmp, y_tmp);
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
