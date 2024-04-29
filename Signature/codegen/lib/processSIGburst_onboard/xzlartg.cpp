//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzlartg.cpp
//
// Code generation for function 'xzlartg'
//

// Include files
#include "xzlartg.h"
#include "processSIGburst_onboard_rtwutil.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
double xzlartg(double f, double g, double &sn, double &r)
{
  double cs;
  if (g == 0.0) {
    cs = 1.0;
    sn = 0.0;
    r = f;
  } else if (f == 0.0) {
    cs = 0.0;
    sn = 1.0;
    r = g;
  } else {
    double b_scale_tmp;
    double f1;
    double g1;
    double scale;
    double scale_tmp;
    int count;
    f1 = f;
    g1 = g;
    scale_tmp = std::abs(f);
    b_scale_tmp = std::abs(g);
    scale = std::fmax(scale_tmp, b_scale_tmp);
    count = -1;
    if (scale >= 7.4428285367870146E+137) {
      do {
        count++;
        f1 *= 1.3435752215134178E-138;
        g1 *= 1.3435752215134178E-138;
      } while (
          (std::fmax(std::abs(f1), std::abs(g1)) >= 7.4428285367870146E+137) &&
          (count + 1 < 20));
      r = rt_hypotd_snf(f1, g1);
      cs = f1 / r;
      sn = g1 / r;
      for (int i{0}; i <= count; i++) {
        r *= 7.4428285367870146E+137;
      }
    } else if (scale <= 1.3435752215134178E-138) {
      do {
        count++;
        f1 *= 7.4428285367870146E+137;
        g1 *= 7.4428285367870146E+137;
      } while (
          !!(std::fmax(std::abs(f1), std::abs(g1)) <= 1.3435752215134178E-138));
      r = rt_hypotd_snf(f1, g1);
      cs = f1 / r;
      sn = g1 / r;
      for (int i{0}; i <= count; i++) {
        r *= 1.3435752215134178E-138;
      }
    } else {
      r = rt_hypotd_snf(f, g);
      cs = f / r;
      sn = g / r;
    }
    if ((scale_tmp > b_scale_tmp) && (cs < 0.0)) {
      cs = -cs;
      sn = -sn;
      r = -r;
    }
  }
  return cs;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzlartg.cpp)
