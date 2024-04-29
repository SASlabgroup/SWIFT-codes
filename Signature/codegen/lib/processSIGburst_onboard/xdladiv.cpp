//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdladiv.cpp
//
// Code generation for function 'xdladiv'
//

// Include files
#include "xdladiv.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
double xdladiv(double a, double b, double c, double d, double &q)
{
  double aa;
  double ab;
  double bb;
  double cc;
  double cd;
  double cd_tmp;
  double dd;
  double p;
  double r;
  double s;
  aa = a;
  bb = b;
  cc = c;
  dd = d;
  ab = std::fmax(std::abs(a), std::abs(b));
  cd_tmp = std::abs(d);
  r = std::abs(c);
  cd = std::fmax(r, cd_tmp);
  s = 1.0;
  if (ab >= 8.9884656743115785E+307) {
    aa = 0.5 * a;
    bb = 0.5 * b;
    s = 2.0;
  }
  if (cd >= 8.9884656743115785E+307) {
    cc = 0.5 * c;
    dd = 0.5 * d;
    s *= 0.5;
  }
  if (ab <= 2.0041683600089728E-292) {
    aa *= 4.0564819207303341E+31;
    bb *= 4.0564819207303341E+31;
    s /= 4.0564819207303341E+31;
  }
  if (cd <= 2.0041683600089728E-292) {
    cc *= 4.0564819207303341E+31;
    dd *= 4.0564819207303341E+31;
    s *= 4.0564819207303341E+31;
  }
  if (cd_tmp <= r) {
    r = dd / cc;
    cd = 1.0 / (cc + dd * r);
    if (r != 0.0) {
      ab = bb * r;
      cd_tmp = bb * cd;
      if (ab != 0.0) {
        p = (aa + ab) * cd;
      } else {
        p = aa * cd + cd_tmp * r;
      }
      ab = -aa * r;
      if (ab != 0.0) {
        q = (bb + ab) * cd;
      } else {
        q = cd_tmp + -aa * cd * r;
      }
    } else {
      p = (aa + dd * (bb / cc)) * cd;
      q = (bb + dd * (-aa / cc)) * cd;
    }
  } else {
    r = cc / dd;
    cd = 1.0 / (dd + cc * r);
    if (r != 0.0) {
      ab = aa * r;
      cd_tmp = aa * cd;
      if (ab != 0.0) {
        p = (bb + ab) * cd;
      } else {
        p = bb * cd + cd_tmp * r;
      }
      ab = -bb * r;
      if (ab != 0.0) {
        q = (aa + ab) * cd;
      } else {
        q = cd_tmp + -bb * cd * r;
      }
    } else {
      p = (bb + cc * (aa / dd)) * cd;
      q = (aa + cc * (-bb / dd)) * cd;
    }
    q = -q;
  }
  p *= s;
  q *= s;
  return p;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdladiv.cpp)
