//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzgebal.cpp
//
// Code generation for function 'xzgebal'
//

// Include files
#include "xzgebal.h"
#include "rt_nonfinite.h"
#include "xnrm2.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
int xzgebal(::coder::array<double, 2U> &A, ::coder::array<double, 1U> &scale,
            int &ihi)
{
  int i;
  int ilo;
  int k;
  int kend;
  int n;
  bool converged;
  bool notdone;
  n = A.size(0);
  scale.set_size(A.size(0));
  kend = A.size(0);
  for (i = 0; i < kend; i++) {
    scale[i] = 1.0;
  }
  k = 0;
  ihi = A.size(0);
  converged = (A.size(0) == 0);
  notdone = (A.size(1) == 0);
  if (converged || notdone) {
    ilo = 1;
    ihi = n;
  } else {
    double b_scale;
    int c_tmp;
    int exitg5;
    int ix;
    int ix0_tmp;
    int iy;
    notdone = true;
    do {
      exitg5 = 0;
      if (notdone) {
        int exitg4;
        notdone = false;
        c_tmp = ihi;
        do {
          exitg4 = 0;
          if (c_tmp > 0) {
            bool exitg6;
            converged = false;
            ix = 0;
            exitg6 = false;
            while ((!exitg6) && (ix <= ihi - 1)) {
              if ((ix + 1 == c_tmp) ||
                  (!(A[(c_tmp + A.size(0) * ix) - 1] != 0.0))) {
                ix++;
              } else {
                converged = true;
                exitg6 = true;
              }
            }
            if (converged) {
              c_tmp--;
            } else {
              scale[ihi - 1] = c_tmp;
              if (c_tmp != ihi) {
                int temp_tmp;
                ix = (c_tmp - 1) * n;
                iy = (ihi - 1) * n;
                for (int b_k{0}; b_k < ihi; b_k++) {
                  temp_tmp = ix + b_k;
                  b_scale = A[temp_tmp];
                  i = iy + b_k;
                  A[temp_tmp] = A[i];
                  A[i] = b_scale;
                }
                for (int b_k{0}; b_k < n; b_k++) {
                  temp_tmp = b_k * n;
                  ix0_tmp = (c_tmp + temp_tmp) - 1;
                  b_scale = A[ix0_tmp];
                  i = (ihi + temp_tmp) - 1;
                  A[ix0_tmp] = A[i];
                  A[i] = b_scale;
                }
              }
              exitg4 = 1;
            }
          } else {
            exitg4 = 2;
          }
        } while (exitg4 == 0);
        if (exitg4 == 1) {
          if (ihi == 1) {
            ilo = 1;
            ihi = 1;
            exitg5 = 1;
          } else {
            ihi--;
            notdone = true;
          }
        }
      } else {
        notdone = true;
        while (notdone) {
          bool exitg6;
          notdone = false;
          c_tmp = k;
          exitg6 = false;
          while ((!exitg6) && (c_tmp + 1 <= ihi)) {
            bool exitg7;
            converged = false;
            ix = k;
            exitg7 = false;
            while ((!exitg7) && (ix + 1 <= ihi)) {
              if ((ix + 1 == c_tmp + 1) ||
                  (!(A[ix + A.size(0) * c_tmp] != 0.0))) {
                ix++;
              } else {
                converged = true;
                exitg7 = true;
              }
            }
            if (converged) {
              c_tmp++;
            } else {
              scale[k] = c_tmp + 1;
              if (c_tmp + 1 != k + 1) {
                int temp_tmp;
                ix = c_tmp * n;
                kend = k * n;
                for (int b_k{0}; b_k < ihi; b_k++) {
                  temp_tmp = ix + b_k;
                  b_scale = A[temp_tmp];
                  i = kend + b_k;
                  A[temp_tmp] = A[i];
                  A[i] = b_scale;
                }
                ix = kend + c_tmp;
                iy = kend + k;
                kend = n - k;
                for (int b_k{0}; b_k < kend; b_k++) {
                  temp_tmp = b_k * n;
                  ix0_tmp = ix + temp_tmp;
                  b_scale = A[ix0_tmp];
                  i = iy + temp_tmp;
                  A[ix0_tmp] = A[i];
                  A[i] = b_scale;
                }
              }
              k++;
              notdone = true;
              exitg6 = true;
            }
          }
        }
        ilo = k + 1;
        converged = false;
        exitg5 = 2;
      }
    } while (exitg5 == 0);
    if (exitg5 != 1) {
      bool exitg3;
      exitg3 = false;
      while ((!exitg3) && (!converged)) {
        int exitg2;
        converged = true;
        ix = k;
        do {
          exitg2 = 0;
          if (ix + 1 <= ihi) {
            double absxk;
            double c;
            double ca;
            double r;
            double t;
            kend = ihi - k;
            c_tmp = ix * n;
            c = blas::xnrm2(kend, A, (c_tmp + k) + 1);
            ix0_tmp = k * n + ix;
            r = 0.0;
            if ((kend >= 1) && (n >= 1)) {
              if (kend == 1) {
                r = std::abs(A[ix0_tmp]);
              } else {
                b_scale = 3.3121686421112381E-170;
                kend = (ix0_tmp + (kend - 1) * n) + 1;
                for (int b_k{ix0_tmp + 1}; n < 0 ? b_k >= kend : b_k <= kend;
                     b_k += n) {
                  absxk = std::abs(A[b_k - 1]);
                  if (absxk > b_scale) {
                    t = b_scale / absxk;
                    r = r * t * t + 1.0;
                    b_scale = absxk;
                  } else {
                    t = absxk / b_scale;
                    r += t * t;
                  }
                }
                r = b_scale * std::sqrt(r);
              }
            }
            if (ihi < 1) {
              kend = 0;
            } else {
              kend = 1;
              if (ihi > 1) {
                b_scale = std::abs(A[c_tmp]);
                for (int b_k{2}; b_k <= ihi; b_k++) {
                  t = std::abs(A[(c_tmp + b_k) - 1]);
                  if (t > b_scale) {
                    kend = b_k;
                    b_scale = t;
                  }
                }
              }
            }
            ca = std::abs(A[(kend + A.size(0) * ix) - 1]);
            iy = n - k;
            if ((iy < 1) || (n < 1)) {
              kend = 0;
            } else {
              kend = 1;
              if (iy > 1) {
                b_scale = std::abs(A[ix0_tmp]);
                for (int b_k{2}; b_k <= iy; b_k++) {
                  t = std::abs(A[ix0_tmp + (b_k - 1) * n]);
                  if (t > b_scale) {
                    kend = b_k;
                    b_scale = t;
                  }
                }
              }
            }
            b_scale = std::abs(A[ix + A.size(0) * ((kend + k) - 1)]);
            if ((c == 0.0) || (r == 0.0)) {
              ix++;
            } else {
              double f;
              int exitg1;
              absxk = r / 2.0;
              f = 1.0;
              t = c + r;
              do {
                exitg1 = 0;
                if ((c < absxk) &&
                    (std::fmax(f, std::fmax(c, ca)) < 4.9896007738368E+291) &&
                    (std::fmin(r, std::fmin(absxk, b_scale)) >
                     2.0041683600089728E-292)) {
                  if (std::isnan(((((c + f) + ca) + r) + absxk) + b_scale)) {
                    exitg1 = 1;
                  } else {
                    f *= 2.0;
                    c *= 2.0;
                    ca *= 2.0;
                    r /= 2.0;
                    absxk /= 2.0;
                    b_scale /= 2.0;
                  }
                } else {
                  absxk = c / 2.0;
                  while ((absxk >= r) &&
                         (std::fmax(r, b_scale) < 4.9896007738368E+291) &&
                         (std::fmin(std::fmin(f, c), std::fmin(absxk, ca)) >
                          2.0041683600089728E-292)) {
                    f /= 2.0;
                    c /= 2.0;
                    absxk /= 2.0;
                    ca /= 2.0;
                    r *= 2.0;
                    b_scale *= 2.0;
                  }
                  if ((!(c + r >= 0.95 * t)) &&
                      ((!(f < 1.0)) || (!(scale[ix] < 1.0)) ||
                       (!(f * scale[ix] <= 1.0020841800044864E-292))) &&
                      ((!(f > 1.0)) || (!(scale[ix] > 1.0)) ||
                       (!(scale[ix] >= 9.9792015476736E+291 / f)))) {
                    b_scale = 1.0 / f;
                    scale[ix] = scale[ix] * f;
                    kend = ix0_tmp + 1;
                    if (n >= 1) {
                      i = (ix0_tmp + n * (iy - 1)) + 1;
                      for (int b_k{kend}; n < 0 ? b_k >= i : b_k <= i;
                           b_k += n) {
                        A[b_k - 1] = b_scale * A[b_k - 1];
                      }
                    }
                    i = c_tmp + ihi;
                    for (int b_k{c_tmp + 1}; b_k <= i; b_k++) {
                      A[b_k - 1] = f * A[b_k - 1];
                    }
                    converged = false;
                  }
                  exitg1 = 2;
                }
              } while (exitg1 == 0);
              if (exitg1 == 1) {
                exitg2 = 2;
              } else {
                ix++;
              }
            }
          } else {
            exitg2 = 1;
          }
        } while (exitg2 == 0);
        if (exitg2 != 1) {
          exitg3 = true;
        }
      }
    }
  }
  return ilo;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzgebal.cpp)
