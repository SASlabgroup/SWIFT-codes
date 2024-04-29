//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eigStandard.cpp
//
// Code generation for function 'eigStandard'
//

// Include files
#include "eigStandard.h"
#include "processSIGburst_onboard_rtwutil.h"
#include "rt_nonfinite.h"
#include "xdlahqr.h"
#include "xdtrevc3.h"
#include "xnrm2.h"
#include "xzgebal.h"
#include "xzgehrd.h"
#include "xzlascl.h"
#include "xzunghr.h"
#include <algorithm>
#include <cmath>

// Function Definitions
namespace coder {
void eigStandard(const double A[16384], creal_T V[16384], creal_T D[128])
{
  static double b_A[16384];
  static double vr[16384];
  double absxk;
  double anrm;
  int ihi;
  int k;
  bool exitg1;
  std::copy(&A[0], &A[16384], &b_A[0]);
  anrm = 0.0;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 16384)) {
    absxk = std::abs(A[k]);
    if (std::isnan(absxk)) {
      anrm = rtNaN;
      exitg1 = true;
    } else {
      if (absxk > anrm) {
        anrm = absxk;
      }
      k++;
    }
  }
  if (std::isinf(anrm) || std::isnan(anrm)) {
    for (int i{0}; i < 128; i++) {
      D[i].re = rtNaN;
      D[i].im = 0.0;
    }
    for (int b_i{0}; b_i < 16384; b_i++) {
      V[b_i].re = rtNaN;
      V[b_i].im = 0.0;
    }
  } else {
    double scale[128];
    double wi[128];
    double wr[128];
    double tau[127];
    double cscale;
    int ilo;
    int info;
    bool scalea;
    cscale = anrm;
    scalea = false;
    if ((anrm > 0.0) && (anrm < 6.7178761075670888E-139)) {
      scalea = true;
      cscale = 6.7178761075670888E-139;
      internal::reflapack::xzlascl(anrm, cscale, b_A);
    } else if (anrm > 1.4885657073574029E+138) {
      scalea = true;
      cscale = 1.4885657073574029E+138;
      internal::reflapack::xzlascl(anrm, cscale, b_A);
    }
    ilo = internal::reflapack::xzgebal(b_A, ihi, scale);
    internal::reflapack::xzgehrd(b_A, ilo, ihi, tau);
    std::copy(&b_A[0], &b_A[16384], &vr[0]);
    internal::reflapack::xzunghr(ilo, ihi, vr, tau);
    info = internal::reflapack::xdlahqr(ilo, ihi, b_A, ilo, ihi, vr, wr, wi);
    if (info == 0) {
      double s;
      int b_i;
      int b_temp_tmp;
      int count;
      int temp_tmp;
      internal::reflapack::xdtrevc3(b_A, vr);
      if (ilo != ihi) {
        for (int i{ilo}; i <= ihi; i++) {
          b_i = i + 16256;
          for (k = i; k <= b_i; k += 128) {
            vr[k - 1] *= scale[i - 1];
          }
        }
      }
      b_i = ilo - 1;
      for (int i{b_i}; i >= 1; i--) {
        s = scale[i - 1];
        if (static_cast<int>(s) != i) {
          for (k = 0; k < 128; k++) {
            temp_tmp = k << 7;
            b_temp_tmp = (i + temp_tmp) - 1;
            absxk = vr[b_temp_tmp];
            count = (static_cast<int>(s) + temp_tmp) - 1;
            vr[b_temp_tmp] = vr[count];
            vr[count] = absxk;
          }
        }
      }
      b_i = ihi + 1;
      for (int i{b_i}; i < 129; i++) {
        s = scale[i - 1];
        if (static_cast<int>(s) != i) {
          for (k = 0; k < 128; k++) {
            temp_tmp = k << 7;
            b_temp_tmp = (i + temp_tmp) - 1;
            absxk = vr[b_temp_tmp];
            count = (static_cast<int>(s) + temp_tmp) - 1;
            vr[b_temp_tmp] = vr[count];
            vr[count] = absxk;
          }
        }
      }
      for (int i{0}; i < 128; i++) {
        s = wi[i];
        if (!(s < 0.0)) {
          if ((i + 1 != 128) && (s > 0.0)) {
            double cs;
            double g1;
            int scl_tmp;
            b_temp_tmp = i << 7;
            scl_tmp = (i + 1) << 7;
            absxk = 1.0 / rt_hypotd_snf(
                              internal::blas::xnrm2(128, vr, b_temp_tmp + 1),
                              internal::blas::xnrm2(128, vr, scl_tmp + 1));
            b_i = b_temp_tmp + 128;
            for (k = b_temp_tmp + 1; k <= b_i; k++) {
              vr[k - 1] *= absxk;
            }
            b_i = scl_tmp + 128;
            for (k = scl_tmp + 1; k <= b_i; k++) {
              vr[k - 1] *= absxk;
            }
            for (ihi = 0; ihi < 128; ihi++) {
              s = vr[ihi + b_temp_tmp];
              absxk = vr[ihi + scl_tmp];
              scale[ihi] = s * s + absxk * absxk;
            }
            k = 0;
            absxk = std::abs(scale[0]);
            for (count = 0; count < 127; count++) {
              s = std::abs(scale[count + 1]);
              if (s > absxk) {
                k = count + 1;
                absxk = s;
              }
            }
            b_i = k + scl_tmp;
            g1 = vr[b_i];
            if (g1 == 0.0) {
              cs = 1.0;
              g1 = 0.0;
            } else {
              s = vr[k + b_temp_tmp];
              if (s == 0.0) {
                cs = 0.0;
                g1 = 1.0;
              } else {
                double b_scale_tmp;
                double scale_tmp;
                scale_tmp = std::abs(s);
                b_scale_tmp = std::abs(g1);
                absxk = std::fmax(scale_tmp, b_scale_tmp);
                count = 0;
                if (absxk >= 7.4428285367870146E+137) {
                  do {
                    count++;
                    s *= 1.3435752215134178E-138;
                    g1 *= 1.3435752215134178E-138;
                  } while ((std::fmax(std::abs(s), std::abs(g1)) >=
                            7.4428285367870146E+137) &&
                           (count < 20));
                  absxk = rt_hypotd_snf(s, g1);
                  cs = s / absxk;
                  g1 /= absxk;
                } else if (absxk <= 1.3435752215134178E-138) {
                  do {
                    s *= 7.4428285367870146E+137;
                    g1 *= 7.4428285367870146E+137;
                  } while (!!(std::fmax(std::abs(s), std::abs(g1)) <=
                              1.3435752215134178E-138));
                  absxk = rt_hypotd_snf(s, g1);
                  cs = s / absxk;
                  g1 /= absxk;
                } else {
                  absxk = rt_hypotd_snf(s, g1);
                  cs = s / absxk;
                  g1 /= absxk;
                }
                if ((scale_tmp > b_scale_tmp) && (cs < 0.0)) {
                  cs = -cs;
                  g1 = -g1;
                }
              }
            }
            for (k = 0; k < 128; k++) {
              count = scl_tmp + k;
              absxk = vr[count];
              temp_tmp = b_temp_tmp + k;
              s = vr[temp_tmp];
              vr[count] = cs * absxk - g1 * s;
              vr[temp_tmp] = cs * s + g1 * absxk;
            }
            vr[b_i] = 0.0;
          } else {
            count = i << 7;
            absxk = 1.0 / internal::blas::xnrm2(128, vr, count + 1);
            b_i = count + 128;
            for (k = count + 1; k <= b_i; k++) {
              vr[k - 1] *= absxk;
            }
          }
        }
      }
      for (b_i = 0; b_i < 16384; b_i++) {
        V[b_i].re = vr[b_i];
        V[b_i].im = 0.0;
      }
      for (ihi = 0; ihi < 127; ihi++) {
        if ((wi[ihi] > 0.0) && (wi[ihi + 1] < 0.0)) {
          for (int i{0}; i < 128; i++) {
            count = i + (ihi << 7);
            absxk = V[count].re;
            temp_tmp = i + ((ihi + 1) << 7);
            s = V[temp_tmp].re;
            V[count].re = absxk;
            V[count].im = s;
            V[temp_tmp].re = absxk;
            V[temp_tmp].im = -s;
          }
        }
      }
    } else {
      for (int b_i{0}; b_i < 16384; b_i++) {
        V[b_i].re = rtNaN;
        V[b_i].im = 0.0;
      }
    }
    if (scalea) {
      internal::reflapack::xzlascl(cscale, anrm, 128 - info, wr, info + 1);
      internal::reflapack::xzlascl(cscale, anrm, 128 - info, wi, info + 1);
      if (info != 0) {
        internal::reflapack::xzlascl(cscale, anrm, ilo - 1, wr, 1);
        internal::reflapack::xzlascl(cscale, anrm, ilo - 1, wi, 1);
      }
    }
    if (info != 0) {
      for (int i{ilo}; i <= info; i++) {
        wr[i - 1] = rtNaN;
        wi[i - 1] = 0.0;
      }
    }
    for (int i{0}; i < 128; i++) {
      D[i].re = wr[i];
      D[i].im = wi[i];
    }
  }
}

} // namespace coder

// End of code generation (eigStandard.cpp)
