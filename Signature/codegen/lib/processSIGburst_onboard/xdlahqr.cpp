//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdlahqr.cpp
//
// Code generation for function 'xdlahqr'
//

// Include files
#include "xdlahqr.h"
#include "rt_nonfinite.h"
#include "xdlanv2.h"
#include "xzlarfg.h"
#include <cmath>

// Function Declarations
static int div_nzp_s32(int numerator, int denominator);

// Function Definitions
static int div_nzp_s32(int numerator, int denominator)
{
  int quotient;
  unsigned int tempAbsQuotient;
  unsigned int u;
  if (numerator < 0) {
    tempAbsQuotient = ~static_cast<unsigned int>(numerator) + 1U;
  } else {
    tempAbsQuotient = static_cast<unsigned int>(numerator);
  }
  if (denominator < 0) {
    u = ~static_cast<unsigned int>(denominator) + 1U;
  } else {
    u = static_cast<unsigned int>(denominator);
  }
  tempAbsQuotient /= u;
  if ((numerator < 0) != (denominator < 0)) {
    quotient = -static_cast<int>(tempAbsQuotient);
  } else {
    quotient = static_cast<int>(tempAbsQuotient);
  }
  return quotient;
}

namespace coder {
namespace internal {
namespace reflapack {
int xdlahqr(int ilo, int ihi, double h[16384], int iloz, int ihiz,
            double z[16384], double wr[128], double wi[128])
{
  double aa;
  double d;
  double h22;
  double rt1r;
  double rt2r;
  double s;
  double s_tmp_tmp;
  int b_i;
  int i;
  int info;
  info = 0;
  i = static_cast<unsigned char>(ilo - 1);
  for (b_i = 0; b_i < i; b_i++) {
    wr[b_i] = h[b_i + (b_i << 7)];
    wi[b_i] = 0.0;
  }
  i = ihi + 1;
  for (b_i = i; b_i < 129; b_i++) {
    wr[b_i - 1] = h[(b_i + ((b_i - 1) << 7)) - 1];
    wi[b_i - 1] = 0.0;
  }
  if (ilo == ihi) {
    wr[ilo - 1] = h[(ilo + ((ilo - 1) << 7)) - 1];
    wi[ilo - 1] = 0.0;
  } else {
    double smlnum;
    int i1;
    int itmax;
    int j;
    int kdefl;
    int nh;
    int nz;
    bool exitg1;
    i = ihi - 3;
    for (j = ilo; j <= i; j++) {
      i1 = j + ((j - 1) << 7);
      h[i1 + 1] = 0.0;
      h[i1 + 2] = 0.0;
    }
    if (ilo <= ihi - 2) {
      h[(ihi + ((ihi - 3) << 7)) - 1] = 0.0;
    }
    nh = (ihi - ilo) + 1;
    nz = (ihiz - iloz) + 1;
    smlnum = 2.2250738585072014E-308 *
             (static_cast<double>(nh) / 2.2204460492503131E-16);
    if (nh < 10) {
      nh = 10;
    }
    itmax = 30 * nh;
    kdefl = 0;
    b_i = ihi - 1;
    exitg1 = false;
    while ((!exitg1) && (b_i + 1 >= ilo)) {
      double h21;
      double tst;
      int b_k;
      int i2;
      int its;
      int k;
      int l;
      int nr;
      bool converged;
      bool exitg2;
      l = ilo;
      converged = false;
      its = 0;
      exitg2 = false;
      while ((!exitg2) && (its <= itmax)) {
        double tr;
        bool exitg3;
        k = b_i;
        exitg3 = false;
        while ((!exitg3) && (k + 1 > l)) {
          i = k + ((k - 1) << 7);
          d = std::abs(h[i]);
          if (d <= smlnum) {
            exitg3 = true;
          } else {
            nh = k + (k << 7);
            h21 = h[nh];
            tr = std::abs(h21);
            aa = h[i - 1];
            tst = std::abs(aa) + tr;
            if (tst == 0.0) {
              if (k - 1 >= ilo) {
                tst = std::abs(h[(k + ((k - 2) << 7)) - 1]);
              }
              if (k + 2 <= ihi) {
                tst += std::abs(h[nh + 1]);
              }
            }
            if (d <= 2.2204460492503131E-16 * tst) {
              h22 = std::abs(h[nh - 1]);
              h21 = std::abs(aa - h21);
              aa = std::fmax(tr, h21);
              tst = std::fmin(tr, h21);
              s = aa + tst;
              if (std::fmin(d, h22) * (std::fmax(d, h22) / s) <=
                  std::fmax(smlnum,
                            2.2204460492503131E-16 * (tst * (aa / s)))) {
                exitg3 = true;
              } else {
                k--;
              }
            } else {
              k--;
            }
          }
        }
        l = k + 1;
        if (k + 1 > ilo) {
          h[k + ((k - 1) << 7)] = 0.0;
        }
        if (k + 1 >= b_i) {
          converged = true;
          exitg2 = true;
        } else {
          double v[3];
          int m;
          kdefl++;
          if (kdefl - div_nzp_s32(kdefl, 20) * 20 == 0) {
            s = std::abs(h[b_i + ((b_i - 1) << 7)]) +
                std::abs(h[(b_i + ((b_i - 2) << 7)) - 1]);
            tst = 0.75 * s + h[b_i + (b_i << 7)];
            aa = -0.4375 * s;
            h21 = s;
            h22 = tst;
          } else if (kdefl - div_nzp_s32(kdefl, 10) * 10 == 0) {
            nh = k + (k << 7);
            s = std::abs(h[nh + 1]) + std::abs(h[(k + ((k + 1) << 7)) + 2]);
            tst = 0.75 * s + h[nh];
            aa = -0.4375 * s;
            h21 = s;
            h22 = tst;
          } else {
            nh = b_i + ((b_i - 1) << 7);
            tst = h[nh - 1];
            h21 = h[nh];
            nh = b_i + (b_i << 7);
            aa = h[nh - 1];
            h22 = h[nh];
          }
          s = ((std::abs(tst) + std::abs(aa)) + std::abs(h21)) + std::abs(h22);
          if (s == 0.0) {
            rt1r = 0.0;
            tr = 0.0;
            rt2r = 0.0;
            h22 = 0.0;
          } else {
            tst /= s;
            h21 /= s;
            aa /= s;
            h22 /= s;
            tr = (tst + h22) / 2.0;
            tst = (tst - tr) * (h22 - tr) - aa * h21;
            h21 = std::sqrt(std::abs(tst));
            if (tst >= 0.0) {
              rt1r = tr * s;
              rt2r = rt1r;
              tr = h21 * s;
              h22 = -tr;
            } else {
              rt1r = tr + h21;
              rt2r = tr - h21;
              if (std::abs(rt1r - h22) <= std::abs(rt2r - h22)) {
                rt1r *= s;
                rt2r = rt1r;
              } else {
                rt2r *= s;
                rt1r = rt2r;
              }
              tr = 0.0;
              h22 = 0.0;
            }
          }
          m = b_i - 1;
          exitg3 = false;
          while ((!exitg3) && (m >= k + 1)) {
            nh = m + ((m - 1) << 7);
            tst = h[nh];
            s_tmp_tmp = h[nh - 1];
            h21 = s_tmp_tmp - rt2r;
            s = (std::abs(h21) + std::abs(h22)) + std::abs(tst);
            aa = tst / s;
            nh = m + (m << 7);
            v[0] = (aa * h[nh - 1] + h21 * (h21 / s)) - tr * (h22 / s);
            tst = h[nh];
            v[1] = aa * (((s_tmp_tmp + tst) - rt1r) - rt2r);
            v[2] = aa * h[nh + 1];
            s = (std::abs(v[0]) + std::abs(v[1])) + std::abs(v[2]);
            v[0] /= s;
            v[1] /= s;
            v[2] /= s;
            if (m == k + 1) {
              exitg3 = true;
            } else {
              i = m + ((m - 2) << 7);
              if (std::abs(h[i - 1]) * (std::abs(v[1]) + std::abs(v[2])) <=
                  2.2204460492503131E-16 * std::abs(v[0]) *
                      ((std::abs(h[i - 2]) + std::abs(s_tmp_tmp)) +
                       std::abs(tst))) {
                exitg3 = true;
              } else {
                m--;
              }
            }
          }
          for (int c_k{m}; c_k <= b_i; c_k++) {
            nh = (b_i - c_k) + 2;
            if (nh >= 3) {
              nr = 3;
            } else {
              nr = nh;
            }
            if (c_k > m) {
              nh = (((c_k - 2) << 7) + c_k) - 1;
              for (b_k = 0; b_k < nr; b_k++) {
                v[b_k] = h[nh + b_k];
              }
            }
            tst = v[0];
            tr = xzlarfg(nr, tst, v);
            if (c_k > m) {
              i = c_k + ((c_k - 2) << 7);
              h[i - 1] = tst;
              h[i] = 0.0;
              if (c_k < b_i) {
                h[i + 1] = 0.0;
              }
            } else if (m > k + 1) {
              i = (c_k + ((c_k - 2) << 7)) - 1;
              h[i] *= 1.0 - tr;
            }
            d = v[1];
            tst = tr * v[1];
            if (nr == 3) {
              s_tmp_tmp = v[2];
              aa = tr * v[2];
              for (j = c_k; j < 129; j++) {
                i = c_k + ((j - 1) << 7);
                rt2r = h[i - 1];
                rt1r = h[i];
                s = h[i + 1];
                h21 = (rt2r + d * rt1r) + s_tmp_tmp * s;
                rt2r -= h21 * tr;
                h[i - 1] = rt2r;
                rt1r -= h21 * tst;
                h[i] = rt1r;
                s -= h21 * aa;
                h[i + 1] = s;
              }
              if (c_k + 3 <= b_i + 1) {
                i = c_k;
              } else {
                i = b_i - 2;
              }
              i = static_cast<unsigned char>(i + 3);
              for (j = 0; j < i; j++) {
                i1 = j + ((c_k - 1) << 7);
                rt2r = h[i1];
                i2 = j + (c_k << 7);
                rt1r = h[i2];
                nh = j + ((c_k + 1) << 7);
                s = h[nh];
                h21 = (rt2r + d * rt1r) + s_tmp_tmp * s;
                rt2r -= h21 * tr;
                h[i1] = rt2r;
                rt1r -= h21 * tst;
                h[i2] = rt1r;
                s -= h21 * aa;
                h[nh] = s;
              }
              for (j = iloz; j <= ihiz; j++) {
                i = (j + ((c_k - 1) << 7)) - 1;
                rt2r = z[i];
                i1 = (j + (c_k << 7)) - 1;
                rt1r = z[i1];
                i2 = (j + ((c_k + 1) << 7)) - 1;
                s = z[i2];
                h21 = (rt2r + d * rt1r) + s_tmp_tmp * s;
                rt2r -= h21 * tr;
                z[i] = rt2r;
                rt1r -= h21 * tst;
                z[i1] = rt1r;
                s -= h21 * aa;
                z[i2] = s;
              }
            } else if (nr == 2) {
              for (j = c_k; j < 129; j++) {
                i = c_k + ((j - 1) << 7);
                s_tmp_tmp = h[i - 1];
                rt2r = h[i];
                h21 = s_tmp_tmp + d * rt2r;
                s_tmp_tmp -= h21 * tr;
                h[i - 1] = s_tmp_tmp;
                rt2r -= h21 * tst;
                h[i] = rt2r;
              }
              i = static_cast<unsigned char>(b_i + 1);
              for (j = 0; j < i; j++) {
                i1 = j + ((c_k - 1) << 7);
                s_tmp_tmp = h[i1];
                i2 = j + (c_k << 7);
                rt2r = h[i2];
                h21 = s_tmp_tmp + d * rt2r;
                s_tmp_tmp -= h21 * tr;
                h[i1] = s_tmp_tmp;
                rt2r -= h21 * tst;
                h[i2] = rt2r;
              }
              for (j = iloz; j <= ihiz; j++) {
                i = (j + ((c_k - 1) << 7)) - 1;
                s_tmp_tmp = z[i];
                i1 = (j + (c_k << 7)) - 1;
                rt2r = z[i1];
                h21 = s_tmp_tmp + d * rt2r;
                s_tmp_tmp -= h21 * tr;
                z[i] = s_tmp_tmp;
                rt2r -= h21 * tst;
                z[i1] = rt2r;
              }
            }
          }
          its++;
        }
      }
      if (!converged) {
        info = b_i + 1;
        exitg1 = true;
      } else {
        if (l == b_i + 1) {
          wr[b_i] = h[b_i + (b_i << 7)];
          wi[b_i] = 0.0;
        } else if (l == b_i) {
          i = b_i << 7;
          i1 = b_i + i;
          d = h[i1 - 1];
          i2 = (b_i - 1) << 7;
          nh = b_i + i2;
          s_tmp_tmp = h[nh];
          rt2r = h[i1];
          wr[b_i - 1] = xdlanv2(h[nh - 1], d, s_tmp_tmp, rt2r, wi[b_i - 1],
                                rt1r, s, aa, h22);
          wr[b_i] = rt1r;
          wi[b_i] = s;
          h[i1 - 1] = d;
          h[nh] = s_tmp_tmp;
          h[i1] = rt2r;
          if (b_i + 1 < 128) {
            nh = ((b_i + 1) << 7) + b_i;
            i1 = static_cast<unsigned char>(127 - b_i);
            for (k = 0; k < i1; k++) {
              nr = nh + (k << 7);
              tst = h[nr];
              h21 = h[nr - 1];
              h[nr] = aa * tst - h22 * h21;
              h[nr - 1] = aa * h21 + h22 * tst;
            }
          }
          if (b_i - 1 >= 1) {
            i1 = static_cast<unsigned char>(b_i - 1);
            for (k = 0; k < i1; k++) {
              b_k = i + k;
              tst = h[b_k];
              j = i2 + k;
              h21 = h[j];
              h[b_k] = aa * tst - h22 * h21;
              h[j] = aa * h21 + h22 * tst;
            }
          }
          if (nz >= 1) {
            nh = (i2 + iloz) - 1;
            nr = (i + iloz) - 1;
            i = static_cast<unsigned char>(nz);
            for (k = 0; k < i; k++) {
              b_k = nr + k;
              tst = z[b_k];
              j = nh + k;
              h21 = z[j];
              z[b_k] = aa * tst - h22 * h21;
              z[j] = aa * h21 + h22 * tst;
            }
          }
        }
        kdefl = 0;
        b_i = l - 2;
      }
    }
    for (j = 0; j < 126; j++) {
      for (b_i = j + 3; b_i < 129; b_i++) {
        h[(b_i + (j << 7)) - 1] = 0.0;
      }
    }
  }
  return info;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdlahqr.cpp)
