//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdlanv2.cpp
//
// Code generation for function 'xdlanv2'
//

// Include files
#include "xdlanv2.h"
#include "processSIGburst_onboard_rtwutil.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
double xdlanv2(double *a, double *b, double *c, double *d, double *rt1i,
               double *rt2r, double *rt2i, double *cs, double *sn)
{
  double rt1r;
  if (*c == 0.0) {
    *cs = 1.0;
    *sn = 0.0;
  } else if (*b == 0.0) {
    double temp;
    *cs = 0.0;
    *sn = 1.0;
    temp = *d;
    *d = *a;
    *a = temp;
    *b = -*c;
    *c = 0.0;
  } else {
    double temp;
    temp = *a - *d;
    if ((temp == 0.0) && ((*b < 0.0) != (*c < 0.0))) {
      *cs = 1.0;
      *sn = 0.0;
    } else {
      double bcmax;
      double bcmis;
      double p;
      double scale;
      double z;
      int count;
      int i;
      bool bcmax_tmp;
      p = 0.5 * temp;
      bcmis = std::abs(*b);
      scale = std::abs(*c);
      bcmax_tmp = rtIsNaN(scale);
      if ((bcmis >= scale) || bcmax_tmp) {
        bcmax = bcmis;
      } else {
        bcmax = scale;
      }
      if ((bcmis <= scale) || bcmax_tmp) {
        scale = bcmis;
      }
      if (!(*b < 0.0)) {
        count = 1;
      } else {
        count = -1;
      }
      if (!(*c < 0.0)) {
        i = 1;
      } else {
        i = -1;
      }
      bcmis = scale * static_cast<double>(count) * static_cast<double>(i);
      scale = std::abs(p);
      if ((!(scale >= bcmax)) && (!rtIsNaN(bcmax))) {
        scale = bcmax;
      }
      z = p / scale * p + bcmax / scale * bcmis;
      if (z >= 8.8817841970012523E-16) {
        double tau;
        *a = std::sqrt(scale) * std::sqrt(z);
        if (p < 0.0) {
          *a = -*a;
        }
        z = p + *a;
        *a = *d + z;
        *d -= bcmax / z * bcmis;
        tau = rt_hypotd_snf(*c, z);
        *cs = z / tau;
        *sn = *c / tau;
        *b -= *c;
        *c = 0.0;
      } else {
        double tau;
        bcmax = *b + *c;
        scale = std::abs(temp);
        bcmis = std::abs(bcmax);
        if ((!(scale >= bcmis)) && (!rtIsNaN(bcmis))) {
          scale = bcmis;
        }
        count = 0;
        while ((scale >= 7.4428285367870146E+137) && (count <= 20)) {
          bcmax *= 1.3435752215134178E-138;
          temp *= 1.3435752215134178E-138;
          scale = std::abs(temp);
          bcmis = std::abs(bcmax);
          if ((!(scale >= bcmis)) && (!rtIsNaN(bcmis))) {
            scale = bcmis;
          }
          count++;
        }
        while ((scale <= 1.3435752215134178E-138) && (count <= 20)) {
          bcmax *= 7.4428285367870146E+137;
          temp *= 7.4428285367870146E+137;
          scale = std::abs(temp);
          bcmis = std::abs(bcmax);
          if ((!(scale >= bcmis)) && (!rtIsNaN(bcmis))) {
            scale = bcmis;
          }
          count++;
        }
        tau = rt_hypotd_snf(bcmax, temp);
        *cs = std::sqrt(0.5 * (std::abs(bcmax) / tau + 1.0));
        if (!(bcmax < 0.0)) {
          count = 1;
        } else {
          count = -1;
        }
        *sn = -(0.5 * temp / (tau * *cs)) * static_cast<double>(count);
        bcmax = *a * *cs + *b * *sn;
        scale = -*a * *sn + *b * *cs;
        z = *c * *cs + *d * *sn;
        bcmis = -*c * *sn + *d * *cs;
        *b = scale * *cs + bcmis * *sn;
        *c = -bcmax * *sn + z * *cs;
        temp = 0.5 * ((bcmax * *cs + z * *sn) + (-scale * *sn + bcmis * *cs));
        *a = temp;
        *d = temp;
        if (*c != 0.0) {
          if (*b != 0.0) {
            if ((*b < 0.0) == (*c < 0.0)) {
              bcmis = std::sqrt(std::abs(*b));
              z = std::sqrt(std::abs(*c));
              *a = bcmis * z;
              if (!(*c < 0.0)) {
                p = *a;
              } else {
                p = -*a;
              }
              tau = 1.0 / std::sqrt(std::abs(*b + *c));
              *a = temp + p;
              *d = temp - p;
              *b -= *c;
              *c = 0.0;
              scale = bcmis * tau;
              bcmis = z * tau;
              temp = *cs * scale - *sn * bcmis;
              *sn = *cs * bcmis + *sn * scale;
              *cs = temp;
            }
          } else {
            *b = -*c;
            *c = 0.0;
            temp = *cs;
            *cs = -*sn;
            *sn = temp;
          }
        }
      }
    }
  }
  rt1r = *a;
  *rt2r = *d;
  if (*c == 0.0) {
    *rt1i = 0.0;
    *rt2i = 0.0;
  } else {
    *rt1i = std::sqrt(std::abs(*b)) * std::sqrt(std::abs(*c));
    *rt2i = -*rt1i;
  }
  return rt1r;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdlanv2.cpp)
