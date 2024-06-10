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
#include "coder_array.h"
#include "rt_nonfinite.h"
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
int xdlahqr(int ilo, int ihi, ::coder::array<double, 2U> &h, int iloz, int ihiz,
            ::coder::array<double, 2U> &z, ::coder::array<double, 1U> &wr,
            ::coder::array<double, 1U> &wi)
{
  double d;
  double h12;
  double h22;
  double rt1r;
  double rt2r;
  double s;
  double tr;
  double tst;
  int info;
  int n;
  n = h.size(0);
  wr.set_size(h.size(0));
  wi.set_size(wr.size(0));
  info = 0;
  if ((h.size(0) != 0) && (h.size(1) != 0)) {
    int i;
    int nh;
    for (i = 0; i <= ilo - 2; i++) {
      wr[i] = h[i + h.size(0) * i];
      wi[i] = 0.0;
    }
    nh = ihi + 1;
    for (i = nh; i <= n; i++) {
      wr[i - 1] = h[(i + h.size(0) * (i - 1)) - 1];
      wi[i - 1] = 0.0;
    }
    if (ilo == ihi) {
      wr[ilo - 1] = h[(ilo + h.size(0) * (ilo - 1)) - 1];
      wi[ilo - 1] = 0.0;
    } else {
      double smlnum;
      int itmax;
      int iy;
      int kdefl;
      int nz;
      bool exitg1;
      nh = ihi - 3;
      for (iy = ilo; iy <= nh; iy++) {
        h[(iy + h.size(0) * (iy - 1)) + 1] = 0.0;
        h[(iy + h.size(0) * (iy - 1)) + 2] = 0.0;
      }
      if (ilo <= ihi - 2) {
        h[(ihi + h.size(0) * (ihi - 3)) - 1] = 0.0;
      }
      nh = (ihi - ilo) + 1;
      nz = ihiz - iloz;
      smlnum = 2.2250738585072014E-308 *
               (static_cast<double>(nh) / 2.2204460492503131E-16);
      if (nh < 10) {
        nh = 10;
      }
      itmax = 30 * nh;
      kdefl = 0;
      i = ihi - 1;
      exitg1 = false;
      while ((!exitg1) && (i + 1 >= ilo)) {
        double aa;
        int its;
        int ix0;
        int k;
        int l;
        bool converged;
        bool exitg2;
        l = ilo;
        converged = false;
        its = 0;
        exitg2 = false;
        while ((!exitg2) && (its <= itmax)) {
          bool exitg3;
          k = i;
          exitg3 = false;
          while ((!exitg3) && (k + 1 > l)) {
            h22 = std::abs(h[k + h.size(0) * (k - 1)]);
            if (h22 <= smlnum) {
              exitg3 = true;
            } else {
              h12 = std::abs(h[k + h.size(0) * k]);
              aa = h[(k + h.size(0) * (k - 1)) - 1];
              tst = std::abs(aa) + h12;
              if (tst == 0.0) {
                if (k - 1 >= ilo) {
                  tst = std::abs(h[(k + h.size(0) * (k - 2)) - 1]);
                }
                if (k + 2 <= ihi) {
                  tst += std::abs(h[(k + h.size(0) * k) + 1]);
                }
              }
              if (h22 <= 2.2204460492503131E-16 * tst) {
                bool aa_tmp;
                tr = std::abs(h[(k + h.size(0) * k) - 1]);
                tst = std::abs(aa - h[k + h.size(0) * k]);
                aa_tmp = rtIsNaN(tst);
                if ((h12 >= tst) || aa_tmp) {
                  aa = h12;
                } else {
                  aa = tst;
                }
                if ((h12 <= tst) || aa_tmp) {
                  tst = h12;
                }
                s = aa + tst;
                tst = 2.2204460492503131E-16 * (tst * (aa / s));
                aa_tmp = rtIsNaN(tr);
                if ((h22 <= tr) || aa_tmp) {
                  d = h22;
                } else {
                  d = tr;
                }
                if ((!(h22 >= tr)) && (!aa_tmp)) {
                  h22 = tr;
                }
                if ((smlnum >= tst) || rtIsNaN(tst)) {
                  tst = smlnum;
                }
                if (d * (h22 / s) <= tst) {
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
            h[k + h.size(0) * (k - 1)] = 0.0;
          }
          if (k + 1 >= i) {
            converged = true;
            exitg2 = true;
          } else {
            double v[3];
            int m;
            kdefl++;
            if (kdefl - div_nzp_s32(kdefl, 20) * 20 == 0) {
              s = std::abs(h[i + h.size(0) * (i - 1)]) +
                  std::abs(h[(i + h.size(0) * (i - 2)) - 1]);
              tst = 0.75 * s + h[i + h.size(0) * i];
              h12 = -0.4375 * s;
              aa = s;
              h22 = tst;
            } else if (kdefl - div_nzp_s32(kdefl, 10) * 10 == 0) {
              s = std::abs(h[(k + h.size(0) * k) + 1]) +
                  std::abs(h[(k + h.size(0) * (k + 1)) + 2]);
              tst = 0.75 * s + h[k + h.size(0) * k];
              h12 = -0.4375 * s;
              aa = s;
              h22 = tst;
            } else {
              tst = h[(i + h.size(0) * (i - 1)) - 1];
              aa = h[i + h.size(0) * (i - 1)];
              h12 = h[(i + h.size(0) * i) - 1];
              h22 = h[i + h.size(0) * i];
            }
            s = ((std::abs(tst) + std::abs(h12)) + std::abs(aa)) +
                std::abs(h22);
            if (s == 0.0) {
              rt1r = 0.0;
              h12 = 0.0;
              rt2r = 0.0;
              aa = 0.0;
            } else {
              tst /= s;
              aa /= s;
              h12 /= s;
              h22 /= s;
              tr = (tst + h22) / 2.0;
              tst = (tst - tr) * (h22 - tr) - h12 * aa;
              h12 = std::sqrt(std::abs(tst));
              if (tst >= 0.0) {
                rt1r = tr * s;
                rt2r = rt1r;
                h12 *= s;
                aa = -h12;
              } else {
                rt1r = tr + h12;
                rt2r = tr - h12;
                if (std::abs(rt1r - h22) <= std::abs(rt2r - h22)) {
                  rt1r *= s;
                  rt2r = rt1r;
                } else {
                  rt2r *= s;
                  rt1r = rt2r;
                }
                h12 = 0.0;
                aa = 0.0;
              }
            }
            m = i - 1;
            exitg3 = false;
            while ((!exitg3) && (m >= k + 1)) {
              tst = h[m + h.size(0) * (m - 1)];
              tr = h[(m + h.size(0) * (m - 1)) - 1];
              h22 = tr - rt2r;
              s = (std::abs(h22) + std::abs(aa)) + std::abs(tst);
              tst /= s;
              v[0] = (tst * h[(m + h.size(0) * m) - 1] + h22 * (h22 / s)) -
                     h12 * (aa / s);
              v[1] = tst * (((tr + h[m + h.size(0) * m]) - rt1r) - rt2r);
              v[2] = tst * h[(m + h.size(0) * m) + 1];
              s = (std::abs(v[0]) + std::abs(v[1])) + std::abs(v[2]);
              v[0] /= s;
              v[1] /= s;
              v[2] /= s;
              if ((m == k + 1) ||
                  (std::abs(h[(m + h.size(0) * (m - 2)) - 1]) *
                       (std::abs(v[1]) + std::abs(v[2])) <=
                   2.2204460492503131E-16 * std::abs(v[0]) *
                       ((std::abs(h[(m + h.size(0) * (m - 2)) - 2]) +
                         std::abs(tr)) +
                        std::abs(h[m + h.size(0) * m])))) {
                exitg3 = true;
              } else {
                m--;
              }
            }
            for (int b_k = m; b_k <= i; b_k++) {
              nh = (i - b_k) + 2;
              if (nh >= 3) {
                nh = 3;
              }
              if (b_k > m) {
                ix0 = ((b_k - 2) * n + b_k) - 1;
                for (iy = 0; iy < nh; iy++) {
                  v[iy] = h[ix0 + iy];
                }
              }
              tst = v[0];
              tr = xzlarfg(nh, &tst, v);
              if (b_k > m) {
                h[(b_k + h.size(0) * (b_k - 2)) - 1] = tst;
                h[b_k + h.size(0) * (b_k - 2)] = 0.0;
                if (b_k < i) {
                  h[(b_k + h.size(0) * (b_k - 2)) + 1] = 0.0;
                }
              } else if (m > k + 1) {
                h[(b_k + h.size(0) * (b_k - 2)) - 1] =
                    h[(b_k + h.size(0) * (b_k - 2)) - 1] * (1.0 - tr);
              }
              h22 = v[1];
              tst = tr * v[1];
              if (nh == 3) {
                rt2r = v[2];
                aa = tr * v[2];
                for (iy = b_k; iy <= n; iy++) {
                  rt1r = h[(b_k + h.size(0) * (iy - 1)) - 1];
                  s = h[b_k + h.size(0) * (iy - 1)];
                  d = h[(b_k + h.size(0) * (iy - 1)) + 1];
                  h12 = (rt1r + h22 * s) + rt2r * d;
                  rt1r -= h12 * tr;
                  h[(b_k + h.size(0) * (iy - 1)) - 1] = rt1r;
                  s -= h12 * tst;
                  h[b_k + h.size(0) * (iy - 1)] = s;
                  d -= h12 * aa;
                  h[(b_k + h.size(0) * (iy - 1)) + 1] = d;
                }
                if (b_k + 3 <= i + 1) {
                  nh = b_k + 2;
                } else {
                  nh = i;
                }
                for (iy = 0; iy <= nh; iy++) {
                  rt1r = h[iy + h.size(0) * (b_k - 1)];
                  s = h[iy + h.size(0) * b_k];
                  d = h[iy + h.size(0) * (b_k + 1)];
                  h12 = (rt1r + h22 * s) + rt2r * d;
                  rt1r -= h12 * tr;
                  h[iy + h.size(0) * (b_k - 1)] = rt1r;
                  s -= h12 * tst;
                  h[iy + h.size(0) * b_k] = s;
                  d -= h12 * aa;
                  h[iy + h.size(0) * (b_k + 1)] = d;
                }
                for (iy = iloz; iy <= ihiz; iy++) {
                  rt1r = z[(iy + z.size(0) * (b_k - 1)) - 1];
                  s = z[(iy + z.size(0) * b_k) - 1];
                  d = z[(iy + z.size(0) * (b_k + 1)) - 1];
                  h12 = (rt1r + h22 * s) + rt2r * d;
                  rt1r -= h12 * tr;
                  z[(iy + z.size(0) * (b_k - 1)) - 1] = rt1r;
                  s -= h12 * tst;
                  z[(iy + z.size(0) * b_k) - 1] = s;
                  d -= h12 * aa;
                  z[(iy + z.size(0) * (b_k + 1)) - 1] = d;
                }
              } else if (nh == 2) {
                for (iy = b_k; iy <= n; iy++) {
                  rt2r = h[(b_k + h.size(0) * (iy - 1)) - 1];
                  rt1r = h[b_k + h.size(0) * (iy - 1)];
                  h12 = rt2r + h22 * rt1r;
                  rt2r -= h12 * tr;
                  h[(b_k + h.size(0) * (iy - 1)) - 1] = rt2r;
                  rt1r -= h12 * tst;
                  h[b_k + h.size(0) * (iy - 1)] = rt1r;
                }
                for (iy = 0; iy <= i; iy++) {
                  rt2r = h[iy + h.size(0) * (b_k - 1)];
                  rt1r = h[iy + h.size(0) * b_k];
                  h12 = rt2r + h22 * rt1r;
                  rt2r -= h12 * tr;
                  h[iy + h.size(0) * (b_k - 1)] = rt2r;
                  rt1r -= h12 * tst;
                  h[iy + h.size(0) * b_k] = rt1r;
                }
                for (iy = iloz; iy <= ihiz; iy++) {
                  rt2r = z[(iy + z.size(0) * (b_k - 1)) - 1];
                  rt1r = z[(iy + z.size(0) * b_k) - 1];
                  h12 = rt2r + h22 * rt1r;
                  rt2r -= h12 * tr;
                  z[(iy + z.size(0) * (b_k - 1)) - 1] = rt2r;
                  rt1r -= h12 * tst;
                  z[(iy + z.size(0) * b_k) - 1] = rt1r;
                }
              }
            }
            its++;
          }
        }
        if (!converged) {
          info = i + 1;
          exitg1 = true;
        } else {
          if (l == i + 1) {
            wr[i] = h[i + h.size(0) * i];
            wi[i] = 0.0;
          } else if (l == i) {
            h22 = h[(i + h.size(0) * i) - 1];
            rt2r = h[i + h.size(0) * (i - 1)];
            rt1r = h[i + h.size(0) * i];
            aa = xdlanv2(&h[(i + h.size(0) * (i - 1)) - 1], &h22, &rt2r, &rt1r,
                         &tst, &s, &d, &h12, &tr);
            wi[i - 1] = tst;
            wr[i - 1] = aa;
            wr[i] = s;
            wi[i] = d;
            h[(i + h.size(0) * i) - 1] = h22;
            h[i + h.size(0) * (i - 1)] = rt2r;
            h[i + h.size(0) * i] = rt1r;
            if (n > i + 1) {
              nh = (n - i) - 2;
              if (nh + 1 >= 1) {
                iy = (i + 1) * n + i;
                for (k = 0; k <= nh; k++) {
                  ix0 = iy + k * n;
                  tst = h[ix0];
                  kdefl = ix0 - 1;
                  aa = h[kdefl];
                  h[ix0] = h12 * tst - tr * aa;
                  h[kdefl] = h12 * aa + tr * tst;
                }
              }
            }
            if (i - 1 >= 1) {
              nh = (i - 1) * n;
              iy = i * n;
              for (k = 0; k <= i - 2; k++) {
                kdefl = iy + k;
                tst = h[kdefl];
                ix0 = nh + k;
                aa = h[ix0];
                h[kdefl] = h12 * tst - tr * aa;
                h[ix0] = h12 * aa + tr * tst;
              }
            }
            if (nz + 1 >= 1) {
              nh = ((i - 1) * n + iloz) - 1;
              iy = (i * n + iloz) - 1;
              for (k = 0; k <= nz; k++) {
                kdefl = iy + k;
                tst = z[kdefl];
                ix0 = nh + k;
                aa = z[ix0];
                z[kdefl] = h12 * tst - tr * aa;
                z[ix0] = h12 * aa + tr * tst;
              }
            }
          }
          kdefl = 0;
          i = l - 2;
        }
      }
      if (n > 2) {
        for (iy = 3; iy <= n; iy++) {
          for (i = iy; i <= n; i++) {
            h[(i + h.size(0) * (iy - 3)) - 1] = 0.0;
          }
        }
      }
    }
  }
  return info;
}

int xdlahqr(int ihi, ::coder::array<double, 2U> &h, int ihiz,
            ::coder::array<double, 2U> &z, ::coder::array<double, 1U> &wr,
            ::coder::array<double, 1U> &wi)
{
  double d;
  double h12;
  double h22;
  double rt1r;
  double rt2r;
  double s;
  double tr;
  double tst;
  int info;
  int n;
  n = h.size(0);
  wr.set_size(h.size(0));
  wi.set_size(wr.size(0));
  info = 0;
  if ((h.size(0) != 0) && (h.size(1) != 0)) {
    int i;
    int nr;
    nr = ihi + 1;
    for (i = nr; i <= n; i++) {
      wr[i - 1] = h[(i + h.size(0) * (i - 1)) - 1];
      wi[i - 1] = 0.0;
    }
    if (ihi == 1) {
      wr[0] = h[0];
      wi[0] = 0.0;
    } else {
      double smlnum;
      int itmax;
      int iy;
      int kdefl;
      bool exitg1;
      for (iy = 0; iy <= ihi - 4; iy++) {
        h[(iy + h.size(0) * iy) + 2] = 0.0;
        h[(iy + h.size(0) * iy) + 3] = 0.0;
      }
      if (ihi - 2 >= 1) {
        h[(ihi + h.size(0) * (ihi - 3)) - 1] = 0.0;
      }
      smlnum = 2.2250738585072014E-308 *
               (static_cast<double>(ihi) / 2.2204460492503131E-16);
      if (ihi >= 10) {
        nr = ihi;
      } else {
        nr = 10;
      }
      itmax = 30 * nr;
      kdefl = 0;
      i = ihi - 1;
      exitg1 = false;
      while ((!exitg1) && (i + 1 >= 1)) {
        double aa;
        int its;
        int k;
        int l;
        int u1;
        bool converged;
        bool exitg2;
        l = 1;
        converged = false;
        its = 0;
        exitg2 = false;
        while ((!exitg2) && (its <= itmax)) {
          bool exitg3;
          k = i;
          exitg3 = false;
          while ((!exitg3) && (k + 1 > l)) {
            h22 = std::abs(h[k + h.size(0) * (k - 1)]);
            if (h22 <= smlnum) {
              exitg3 = true;
            } else {
              h12 = std::abs(h[k + h.size(0) * k]);
              aa = h[(k + h.size(0) * (k - 1)) - 1];
              tst = std::abs(aa) + h12;
              if (tst == 0.0) {
                if (k - 1 >= 1) {
                  tst = std::abs(h[(k + h.size(0) * (k - 2)) - 1]);
                }
                if (k + 2 <= ihi) {
                  tst += std::abs(h[(k + h.size(0) * k) + 1]);
                }
              }
              if (h22 <= 2.2204460492503131E-16 * tst) {
                bool aa_tmp;
                tr = std::abs(h[(k + h.size(0) * k) - 1]);
                tst = std::abs(aa - h[k + h.size(0) * k]);
                aa_tmp = rtIsNaN(tst);
                if ((h12 >= tst) || aa_tmp) {
                  aa = h12;
                } else {
                  aa = tst;
                }
                if ((h12 <= tst) || aa_tmp) {
                  tst = h12;
                }
                s = aa + tst;
                tst = 2.2204460492503131E-16 * (tst * (aa / s));
                aa_tmp = rtIsNaN(tr);
                if ((h22 <= tr) || aa_tmp) {
                  d = h22;
                } else {
                  d = tr;
                }
                if ((!(h22 >= tr)) && (!aa_tmp)) {
                  h22 = tr;
                }
                if ((smlnum >= tst) || rtIsNaN(tst)) {
                  tst = smlnum;
                }
                if (d * (h22 / s) <= tst) {
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
          if (k + 1 > 1) {
            h[k + h.size(0) * (k - 1)] = 0.0;
          }
          if (k + 1 >= i) {
            converged = true;
            exitg2 = true;
          } else {
            double v[3];
            int m;
            kdefl++;
            if (kdefl - div_nzp_s32(kdefl, 20) * 20 == 0) {
              s = std::abs(h[i + h.size(0) * (i - 1)]) +
                  std::abs(h[(i + h.size(0) * (i - 2)) - 1]);
              tst = 0.75 * s + h[i + h.size(0) * i];
              h12 = -0.4375 * s;
              aa = s;
              h22 = tst;
            } else if (kdefl - div_nzp_s32(kdefl, 10) * 10 == 0) {
              s = std::abs(h[(k + h.size(0) * k) + 1]) +
                  std::abs(h[(k + h.size(0) * (k + 1)) + 2]);
              tst = 0.75 * s + h[k + h.size(0) * k];
              h12 = -0.4375 * s;
              aa = s;
              h22 = tst;
            } else {
              tst = h[(i + h.size(0) * (i - 1)) - 1];
              aa = h[i + h.size(0) * (i - 1)];
              h12 = h[(i + h.size(0) * i) - 1];
              h22 = h[i + h.size(0) * i];
            }
            s = ((std::abs(tst) + std::abs(h12)) + std::abs(aa)) +
                std::abs(h22);
            if (s == 0.0) {
              rt1r = 0.0;
              h12 = 0.0;
              rt2r = 0.0;
              aa = 0.0;
            } else {
              tst /= s;
              aa /= s;
              h12 /= s;
              h22 /= s;
              tr = (tst + h22) / 2.0;
              tst = (tst - tr) * (h22 - tr) - h12 * aa;
              h12 = std::sqrt(std::abs(tst));
              if (tst >= 0.0) {
                rt1r = tr * s;
                rt2r = rt1r;
                h12 *= s;
                aa = -h12;
              } else {
                rt1r = tr + h12;
                rt2r = tr - h12;
                if (std::abs(rt1r - h22) <= std::abs(rt2r - h22)) {
                  rt1r *= s;
                  rt2r = rt1r;
                } else {
                  rt2r *= s;
                  rt1r = rt2r;
                }
                h12 = 0.0;
                aa = 0.0;
              }
            }
            m = i - 1;
            exitg3 = false;
            while ((!exitg3) && (m >= k + 1)) {
              tst = h[m + h.size(0) * (m - 1)];
              tr = h[(m + h.size(0) * (m - 1)) - 1];
              h22 = tr - rt2r;
              s = (std::abs(h22) + std::abs(aa)) + std::abs(tst);
              tst /= s;
              v[0] = (tst * h[(m + h.size(0) * m) - 1] + h22 * (h22 / s)) -
                     h12 * (aa / s);
              v[1] = tst * (((tr + h[m + h.size(0) * m]) - rt1r) - rt2r);
              v[2] = tst * h[(m + h.size(0) * m) + 1];
              s = (std::abs(v[0]) + std::abs(v[1])) + std::abs(v[2]);
              v[0] /= s;
              v[1] /= s;
              v[2] /= s;
              if ((m == k + 1) ||
                  (std::abs(h[(m + h.size(0) * (m - 2)) - 1]) *
                       (std::abs(v[1]) + std::abs(v[2])) <=
                   2.2204460492503131E-16 * std::abs(v[0]) *
                       ((std::abs(h[(m + h.size(0) * (m - 2)) - 2]) +
                         std::abs(tr)) +
                        std::abs(h[m + h.size(0) * m])))) {
                exitg3 = true;
              } else {
                m--;
              }
            }
            for (int b_k = m; b_k <= i; b_k++) {
              u1 = (i - b_k) + 2;
              if (u1 >= 3) {
                nr = 3;
              } else {
                nr = u1;
              }
              if (b_k > m) {
                iy = ((b_k - 2) * n + b_k) - 1;
                for (u1 = 0; u1 < nr; u1++) {
                  v[u1] = h[iy + u1];
                }
              }
              tst = v[0];
              tr = xzlarfg(nr, &tst, v);
              if (b_k > m) {
                h[(b_k + h.size(0) * (b_k - 2)) - 1] = tst;
                h[b_k + h.size(0) * (b_k - 2)] = 0.0;
                if (b_k < i) {
                  h[(b_k + h.size(0) * (b_k - 2)) + 1] = 0.0;
                }
              } else if (m > k + 1) {
                h[(b_k + h.size(0) * (b_k - 2)) - 1] =
                    h[(b_k + h.size(0) * (b_k - 2)) - 1] * (1.0 - tr);
              }
              h22 = v[1];
              tst = tr * v[1];
              if (nr == 3) {
                rt2r = v[2];
                aa = tr * v[2];
                for (iy = b_k; iy <= n; iy++) {
                  rt1r = h[(b_k + h.size(0) * (iy - 1)) - 1];
                  s = h[b_k + h.size(0) * (iy - 1)];
                  d = h[(b_k + h.size(0) * (iy - 1)) + 1];
                  h12 = (rt1r + h22 * s) + rt2r * d;
                  rt1r -= h12 * tr;
                  h[(b_k + h.size(0) * (iy - 1)) - 1] = rt1r;
                  s -= h12 * tst;
                  h[b_k + h.size(0) * (iy - 1)] = s;
                  d -= h12 * aa;
                  h[(b_k + h.size(0) * (iy - 1)) + 1] = d;
                }
                if (b_k + 3 <= i + 1) {
                  nr = b_k + 2;
                } else {
                  nr = i;
                }
                for (iy = 0; iy <= nr; iy++) {
                  rt1r = h[iy + h.size(0) * (b_k - 1)];
                  s = h[iy + h.size(0) * b_k];
                  d = h[iy + h.size(0) * (b_k + 1)];
                  h12 = (rt1r + h22 * s) + rt2r * d;
                  rt1r -= h12 * tr;
                  h[iy + h.size(0) * (b_k - 1)] = rt1r;
                  s -= h12 * tst;
                  h[iy + h.size(0) * b_k] = s;
                  d -= h12 * aa;
                  h[iy + h.size(0) * (b_k + 1)] = d;
                }
                for (iy = 0; iy < ihiz; iy++) {
                  rt1r = z[iy + z.size(0) * (b_k - 1)];
                  s = z[iy + z.size(0) * b_k];
                  d = z[iy + z.size(0) * (b_k + 1)];
                  h12 = (rt1r + h22 * s) + rt2r * d;
                  rt1r -= h12 * tr;
                  z[iy + z.size(0) * (b_k - 1)] = rt1r;
                  s -= h12 * tst;
                  z[iy + z.size(0) * b_k] = s;
                  d -= h12 * aa;
                  z[iy + z.size(0) * (b_k + 1)] = d;
                }
              } else if (nr == 2) {
                for (iy = b_k; iy <= n; iy++) {
                  rt2r = h[(b_k + h.size(0) * (iy - 1)) - 1];
                  rt1r = h[b_k + h.size(0) * (iy - 1)];
                  h12 = rt2r + h22 * rt1r;
                  rt2r -= h12 * tr;
                  h[(b_k + h.size(0) * (iy - 1)) - 1] = rt2r;
                  rt1r -= h12 * tst;
                  h[b_k + h.size(0) * (iy - 1)] = rt1r;
                }
                for (iy = 0; iy <= i; iy++) {
                  rt2r = h[iy + h.size(0) * (b_k - 1)];
                  rt1r = h[iy + h.size(0) * b_k];
                  h12 = rt2r + h22 * rt1r;
                  rt2r -= h12 * tr;
                  h[iy + h.size(0) * (b_k - 1)] = rt2r;
                  rt1r -= h12 * tst;
                  h[iy + h.size(0) * b_k] = rt1r;
                }
                for (iy = 0; iy < ihiz; iy++) {
                  rt2r = z[iy + z.size(0) * (b_k - 1)];
                  rt1r = z[iy + z.size(0) * b_k];
                  h12 = rt2r + h22 * rt1r;
                  rt2r -= h12 * tr;
                  z[iy + z.size(0) * (b_k - 1)] = rt2r;
                  rt1r -= h12 * tst;
                  z[iy + z.size(0) * b_k] = rt1r;
                }
              }
            }
            its++;
          }
        }
        if (!converged) {
          info = i + 1;
          exitg1 = true;
        } else {
          if (l == i + 1) {
            wr[i] = h[i + h.size(0) * i];
            wi[i] = 0.0;
          } else if (l == i) {
            h22 = h[(i + h.size(0) * i) - 1];
            rt2r = h[i + h.size(0) * (i - 1)];
            rt1r = h[i + h.size(0) * i];
            aa = xdlanv2(&h[(i + h.size(0) * (i - 1)) - 1], &h22, &rt2r, &rt1r,
                         &tst, &s, &d, &h12, &tr);
            wi[i - 1] = tst;
            wr[i - 1] = aa;
            wr[i] = s;
            wi[i] = d;
            h[(i + h.size(0) * i) - 1] = h22;
            h[i + h.size(0) * (i - 1)] = rt2r;
            h[i + h.size(0) * i] = rt1r;
            if (n > i + 1) {
              nr = (n - i) - 2;
              if (nr + 1 >= 1) {
                iy = (i + 1) * n + i;
                for (k = 0; k <= nr; k++) {
                  u1 = iy + k * n;
                  tst = h[u1];
                  kdefl = u1 - 1;
                  aa = h[kdefl];
                  h[u1] = h12 * tst - tr * aa;
                  h[kdefl] = h12 * aa + tr * tst;
                }
              }
            }
            if (i - 1 >= 1) {
              nr = (i - 1) * n;
              iy = i * n;
              for (k = 0; k <= i - 2; k++) {
                kdefl = iy + k;
                tst = h[kdefl];
                u1 = nr + k;
                aa = h[u1];
                h[kdefl] = h12 * tst - tr * aa;
                h[u1] = h12 * aa + tr * tst;
              }
            }
            if (ihiz >= 1) {
              nr = (i - 1) * n;
              iy = i * n;
              for (k = 0; k < ihiz; k++) {
                kdefl = iy + k;
                tst = z[kdefl];
                u1 = nr + k;
                aa = z[u1];
                z[kdefl] = h12 * tst - tr * aa;
                z[u1] = h12 * aa + tr * tst;
              }
            }
          }
          kdefl = 0;
          i = l - 2;
        }
      }
      if (n > 2) {
        for (iy = 3; iy <= n; iy++) {
          for (i = iy; i <= n; i++) {
            h[(i + h.size(0) * (iy - 3)) - 1] = 0.0;
          }
        }
      }
    }
  }
  return info;
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdlahqr.cpp)
