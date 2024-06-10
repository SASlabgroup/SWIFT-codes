//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xgeev.cpp
//
// Code generation for function 'xgeev'
//

// Include files
#include "xgeev.h"
#include "processSIGburst_onboard_lowmem_rtwutil.h"
#include "rt_nonfinite.h"
#include "xdlahqr.h"
#include "xdtrevc3.h"
#include "xnrm2.h"
#include "xzgebal.h"
#include "xzlarf.h"
#include "xzlarfg.h"
#include "xzlascl.h"
#include "xzunghr.h"
#include "coder_array.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace lapack {
int xgeev(const ::coder::array<double, 2U> &A, ::coder::array<creal_T, 1U> &W,
          ::coder::array<creal_T, 2U> &VR)
{
  array<double, 2U> b_A;
  array<double, 2U> vr;
  array<double, 1U> scale;
  array<double, 1U> work;
  array<double, 1U> wr;
  double absxk;
  int i;
  int ihi;
  int info;
  int n;
  int ntau;
  b_A.set_size(A.size(0), A.size(1));
  ntau = A.size(0) * A.size(1);
  for (i = 0; i < ntau; i++) {
    b_A[i] = A[i];
  }
  info = 0;
  n = A.size(0);
  W.set_size(A.size(0));
  VR.set_size(A.size(0), A.size(0));
  if (A.size(0) != 0) {
    double anrm;
    int k;
    bool scalea;
    anrm = 0.0;
    scalea = (A.size(1) == 0);
    if (!scalea) {
      bool exitg1;
      k = 0;
      exitg1 = false;
      while ((!exitg1) && (k <= ntau - 1)) {
        absxk = std::abs(A[k]);
        if (rtIsNaN(absxk)) {
          anrm = rtNaN;
          exitg1 = true;
        } else {
          if (absxk > anrm) {
            anrm = absxk;
          }
          k++;
        }
      }
    }
    if (rtIsInf(anrm) || rtIsNaN(anrm)) {
      W.set_size(A.size(0));
      ntau = A.size(0);
      for (i = 0; i < ntau; i++) {
        W[i].re = rtNaN;
        W[i].im = 0.0;
      }
      VR.set_size(A.size(0), A.size(0));
      ntau = A.size(0) * A.size(0);
      for (i = 0; i < ntau; i++) {
        VR[i].re = rtNaN;
        VR[i].im = 0.0;
      }
    } else {
      double cscale;
      double s;
      int b_n;
      int ilo;
      int in;
      int scl_tmp;
      int u0;
      cscale = anrm;
      scalea = false;
      if ((anrm > 0.0) && (anrm < 6.7178761075670888E-139)) {
        scalea = true;
        cscale = 6.7178761075670888E-139;
        reflapack::xzlascl(anrm, cscale, A.size(0), A.size(0), b_A, A.size(0));
      } else if (anrm > 1.4885657073574029E+138) {
        scalea = true;
        cscale = 1.4885657073574029E+138;
        reflapack::xzlascl(anrm, cscale, A.size(0), A.size(0), b_A, A.size(0));
      }
      ilo = reflapack::xzgebal(b_A, scale, &ihi);
      b_n = b_A.size(0);
      if (b_A.size(0) < 1) {
        ntau = 0;
      } else {
        ntau = b_A.size(0) - 1;
      }
      wr.set_size(ntau);
      if ((ihi - ilo) + 1 > 1) {
        for (int b_i = 0; b_i <= ilo - 2; b_i++) {
          wr[b_i] = 0.0;
        }
        for (int b_i = ihi; b_i <= ntau; b_i++) {
          wr[b_i - 1] = 0.0;
        }
        work.set_size(b_A.size(0));
        ntau = b_A.size(0);
        for (i = 0; i < ntau; i++) {
          work[i] = 0.0;
        }
        i = ihi - 1;
        for (int b_i = ilo; b_i <= i; b_i++) {
          ntau = (b_i - 1) * b_n;
          in = b_i * b_n + 1;
          absxk = b_A[b_i + b_A.size(0) * (b_i - 1)];
          scl_tmp = ihi - b_i;
          u0 = b_i + 2;
          if (u0 > b_n) {
            u0 = b_n;
          }
          s = reflapack::xzlarfg(scl_tmp, &absxk, b_A, u0 + ntau);
          wr[b_i - 1] = s;
          b_A[b_i + b_A.size(0) * (b_i - 1)] = 1.0;
          ntau = (b_i + ntau) + 1;
          reflapack::b_xzlarf(ihi, scl_tmp, ntau, s, b_A, in, b_n, work);
          reflapack::xzlarf(scl_tmp, b_n - b_i, ntau, s, b_A, b_i + in, b_n,
                            work);
          b_A[b_i + b_A.size(0) * (b_i - 1)] = absxk;
        }
      }
      vr.set_size(b_A.size(0), b_A.size(1));
      ntau = b_A.size(0) * b_A.size(1);
      for (i = 0; i < ntau; i++) {
        vr[i] = b_A[i];
      }
      reflapack::xzunghr(A.size(0), ilo, ihi, vr, A.size(0), wr);
      info = reflapack::xdlahqr(ilo, ihi, b_A, ilo, ihi, vr, wr, work);
      if (info == 0) {
        reflapack::xdtrevc3(b_A, vr);
        b_n = vr.size(0);
        if ((vr.size(0) != 0) && (vr.size(1) != 0)) {
          if (ilo != ihi) {
            for (int b_i = ilo; b_i <= ihi; b_i++) {
              if (b_n >= 1) {
                i = b_i + b_n * (b_n - 1);
                for (k = b_i; b_n < 0 ? k >= i : k <= i; k += b_n) {
                  vr[k - 1] = scale[b_i - 1] * vr[k - 1];
                }
              }
            }
          }
          i = ilo - 1;
          for (int b_i = i; b_i >= 1; b_i--) {
            s = scale[b_i - 1];
            if (static_cast<int>(s) != b_i) {
              for (k = 0; k < b_n; k++) {
                ntau = k * b_n;
                u0 = (b_i + ntau) - 1;
                absxk = vr[u0];
                scl_tmp = (static_cast<int>(s) + ntau) - 1;
                vr[u0] = vr[scl_tmp];
                vr[scl_tmp] = absxk;
              }
            }
          }
          i = ihi + 1;
          for (int b_i = i; b_i <= b_n; b_i++) {
            s = scale[b_i - 1];
            if (static_cast<int>(s) != b_i) {
              for (k = 0; k < b_n; k++) {
                ntau = k * b_n;
                u0 = (b_i + ntau) - 1;
                absxk = vr[u0];
                scl_tmp = (static_cast<int>(s) + ntau) - 1;
                vr[u0] = vr[scl_tmp];
                vr[scl_tmp] = absxk;
              }
            }
          }
        }
        for (int b_i = 0; b_i < n; b_i++) {
          if (!(work[b_i] < 0.0)) {
            if ((b_i + 1 != n) && (work[b_i] > 0.0)) {
              double cs;
              double f1;
              double g1;
              in = b_i * n;
              scl_tmp = (b_i + 1) * n;
              absxk = 1.0 / rt_hypotd_snf(blas::xnrm2(n, vr, in + 1),
                                          blas::xnrm2(n, vr, scl_tmp + 1));
              i = in + n;
              for (k = in + 1; k <= i; k++) {
                vr[k - 1] = absxk * vr[k - 1];
              }
              i = scl_tmp + n;
              for (k = scl_tmp + 1; k <= i; k++) {
                vr[k - 1] = absxk * vr[k - 1];
              }
              for (ntau = 0; ntau < n; ntau++) {
                absxk = vr[ntau + vr.size(0) * b_i];
                s = vr[ntau + vr.size(0) * (b_i + 1)];
                scale[ntau] = absxk * absxk + s * s;
              }
              k = 0;
              if (n > 1) {
                absxk = std::abs(scale[0]);
                for (ihi = 2; ihi <= n; ihi++) {
                  s = std::abs(scale[ihi - 1]);
                  if (s > absxk) {
                    k = ihi - 1;
                    absxk = s;
                  }
                }
              }
              f1 = vr[k + vr.size(0) * b_i];
              g1 = vr[k + vr.size(0) * (b_i + 1)];
              if (g1 == 0.0) {
                cs = 1.0;
                f1 = 0.0;
              } else if (f1 == 0.0) {
                cs = 0.0;
                f1 = 1.0;
              } else {
                double b_scale_tmp;
                double scale_tmp;
                scale_tmp = std::abs(f1);
                b_scale_tmp = std::abs(g1);
                if ((scale_tmp >= b_scale_tmp) || rtIsNaN(b_scale_tmp)) {
                  absxk = scale_tmp;
                } else {
                  absxk = b_scale_tmp;
                }
                ntau = 0;
                if (absxk >= 7.4428285367870146E+137) {
                  do {
                    ntau++;
                    f1 *= 1.3435752215134178E-138;
                    g1 *= 1.3435752215134178E-138;
                    absxk = std::abs(f1);
                    s = std::abs(g1);
                    if ((absxk >= s) || rtIsNaN(s)) {
                      s = absxk;
                    }
                  } while ((s >= 7.4428285367870146E+137) && (ntau < 20));
                  absxk = rt_hypotd_snf(f1, g1);
                  cs = f1 / absxk;
                  f1 = g1 / absxk;
                } else if (absxk <= 1.3435752215134178E-138) {
                  do {
                    f1 *= 7.4428285367870146E+137;
                    g1 *= 7.4428285367870146E+137;
                    absxk = std::abs(f1);
                    s = std::abs(g1);
                    if ((absxk >= s) || rtIsNaN(s)) {
                      s = absxk;
                    }
                  } while (!!(s <= 1.3435752215134178E-138));
                  absxk = rt_hypotd_snf(f1, g1);
                  cs = f1 / absxk;
                  f1 = g1 / absxk;
                } else {
                  absxk = rt_hypotd_snf(f1, g1);
                  cs = f1 / absxk;
                  f1 = g1 / absxk;
                }
                if ((scale_tmp > b_scale_tmp) && (cs < 0.0)) {
                  cs = -cs;
                  f1 = -f1;
                }
              }
              for (ihi = 0; ihi < n; ihi++) {
                ntau = scl_tmp + ihi;
                absxk = vr[ntau];
                u0 = in + ihi;
                s = vr[u0];
                vr[ntau] = cs * absxk - f1 * s;
                vr[u0] = cs * s + f1 * absxk;
              }
              vr[k + vr.size(0) * (b_i + 1)] = 0.0;
            } else {
              ntau = b_i * n;
              absxk = 1.0 / blas::xnrm2(n, vr, ntau + 1);
              i = ntau + n;
              for (k = ntau + 1; k <= i; k++) {
                vr[k - 1] = absxk * vr[k - 1];
              }
            }
          }
        }
        VR.set_size(vr.size(0), vr.size(1));
        ntau = vr.size(0) * vr.size(1);
        for (i = 0; i < ntau; i++) {
          VR[i].re = vr[i];
          VR[i].im = 0.0;
        }
        for (ntau = 2; ntau <= n; ntau++) {
          if ((work[ntau - 2] > 0.0) && (work[ntau - 1] < 0.0)) {
            for (int b_i = 0; b_i < n; b_i++) {
              absxk = VR[b_i + VR.size(0) * (ntau - 2)].re;
              s = VR[b_i + VR.size(0) * (ntau - 1)].re;
              VR[b_i + VR.size(0) * (ntau - 2)].re = absxk;
              VR[b_i + VR.size(0) * (ntau - 2)].im = s;
              VR[b_i + VR.size(0) * (ntau - 1)].re = absxk;
              VR[b_i + VR.size(0) * (ntau - 1)].im = -s;
            }
          }
        }
      } else {
        VR.set_size(A.size(0), A.size(0));
        ntau = A.size(0) * A.size(0);
        for (i = 0; i < ntau; i++) {
          VR[i].re = rtNaN;
          VR[i].im = 0.0;
        }
      }
      if (scalea) {
        i = A.size(0) - info;
        reflapack::xzlascl(cscale, anrm, i, wr, info + 1);
        reflapack::xzlascl(cscale, anrm, i, work, info + 1);
        if (info != 0) {
          reflapack::xzlascl(cscale, anrm, ilo - 1, wr, 1);
          reflapack::xzlascl(cscale, anrm, ilo - 1, work, 1);
        }
      }
      if (info != 0) {
        for (int b_i = ilo; b_i <= info; b_i++) {
          wr[b_i - 1] = rtNaN;
          work[b_i - 1] = 0.0;
        }
      }
      W.set_size(wr.size(0));
      ntau = wr.size(0);
      for (i = 0; i < ntau; i++) {
        W[i].re = wr[i];
        W[i].im = work[i];
      }
    }
  }
  return info;
}

} // namespace lapack
} // namespace internal
} // namespace coder

// End of code generation (xgeev.cpp)
