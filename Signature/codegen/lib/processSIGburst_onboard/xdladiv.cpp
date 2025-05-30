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
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
double xdladiv(double a, double b, double c, double d, double *q)
{
  double aa;
  double ab;
  double bb;
  double br;
  double cc;
  double cd;
  double dd;
  double p;
  double r;
  double s;
  aa = a;
  bb = b;
  cc = c;
  dd = d;
  br = std::abs(a);
  ab = std::abs(b);
  if ((br >= ab) || rtIsNaN(ab)) {
    ab = br;
  }
  br = std::abs(d);
  r = std::abs(c);
  if ((r >= br) || rtIsNaN(br)) {
    cd = r;
  } else {
    cd = br;
  }
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
  if (br <= r) {
    r = dd / cc;
    cd = 1.0 / (cc + dd * r);
    if (r != 0.0) {
      br = bb * r;
      ab = bb * cd;
      if (br != 0.0) {
        p = (aa + br) * cd;
      } else {
        p = aa * cd + ab * r;
      }
      br = -aa * r;
      if (br != 0.0) {
        *q = (bb + br) * cd;
      } else {
        *q = ab + -aa * cd * r;
      }
    } else {
      p = (aa + dd * (bb / cc)) * cd;
      *q = (bb + dd * (-aa / cc)) * cd;
    }
  } else {
    r = cc / dd;
    cd = 1.0 / (dd + cc * r);
    if (r != 0.0) {
      br = aa * r;
      ab = aa * cd;
      if (br != 0.0) {
        p = (bb + br) * cd;
      } else {
        p = bb * cd + ab * r;
      }
      br = -bb * r;
      if (br != 0.0) {
        *q = (aa + br) * cd;
      } else {
        *q = ab + -bb * cd * r;
      }
    } else {
      p = (bb + cc * (aa / dd)) * cd;
      *q = (aa + cc * (-bb / dd)) * cd;
    }
    *q = -*q;
  }
  p *= s;
  *q *= s;
  return p;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdladiv.cpp)
