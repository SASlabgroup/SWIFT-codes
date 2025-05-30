//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eigHermitianStandard.cpp
//
// Code generation for function 'eigHermitianStandard'
//

// Include files
#include "eigHermitianStandard.h"
#include "rt_nonfinite.h"
#include "xzlarfg.h"
#include "xzlascl.h"
#include "xzsteqr.h"
#include "xzungqr.h"
#include "coder_array.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions
namespace coder {
void eigHermitianStandard(const ::coder::array<double, 2U> &A,
                          ::coder::array<creal_T, 2U> &V,
                          ::coder::array<creal_T, 1U> &D)
{
  array<double, 2U> b_A;
  array<double, 1U> W;
  array<double, 1U> e;
  array<double, 1U> tau;
  int i;
  int loop_ub_tmp;
  int ntau;
  b_A.set_size(A.size(0), A.size(1));
  loop_ub_tmp = A.size(0) * A.size(1);
  for (i = 0; i < loop_ub_tmp; i++) {
    b_A[i] = A[i];
  }
  W.set_size(A.size(0));
  if (A.size(0) != 0) {
    if (A.size(0) == 1) {
      W[0] = A[0];
      b_A[0] = 1.0;
    } else {
      double absx;
      double anrm;
      int b_i;
      bool exitg2;
      anrm = 0.0;
      ntau = 0;
      exitg2 = false;
      while ((!exitg2) && (ntau <= A.size(0) - 1)) {
        int exitg1;
        b_i = 0;
        do {
          exitg1 = 0;
          if (b_i <= ntau) {
            absx = std::abs(A[b_i + A.size(0) * ntau]);
            if (rtIsNaN(absx)) {
              anrm = rtNaN;
              exitg1 = 1;
            } else {
              if (absx > anrm) {
                anrm = absx;
              }
              b_i++;
            }
          } else {
            ntau++;
            exitg1 = 2;
          }
        } while (exitg1 == 0);
        if (exitg1 == 1) {
          exitg2 = true;
        }
      }
      if (rtIsInf(anrm) || rtIsNaN(anrm)) {
        W.set_size(A.size(0));
        ntau = A.size(0);
        for (i = 0; i < ntau; i++) {
          W[i] = rtNaN;
        }
        b_A.set_size(A.size(0), A.size(1));
        for (i = 0; i < loop_ub_tmp; i++) {
          b_A[i] = rtNaN;
        }
      } else {
        int n;
        bool iscale;
        iscale = false;
        if ((anrm > 0.0) && (anrm < 1.0010415475915505E-146)) {
          iscale = true;
          anrm = 1.0010415475915505E-146 / anrm;
          internal::reflapack::xzlascl(1.0, anrm, A.size(0), A.size(0), b_A,
                                       A.size(0));
        } else if (anrm > 9.9895953610111751E+145) {
          iscale = true;
          anrm = 9.9895953610111751E+145 / anrm;
          internal::reflapack::xzlascl(1.0, anrm, A.size(0), A.size(0), b_A,
                                       A.size(0));
        }
        n = b_A.size(0) - 1;
        if (b_A.size(0) < 1) {
          ntau = 0;
        } else {
          ntau = b_A.size(0) - 1;
        }
        W.set_size(b_A.size(0));
        e.set_size(ntau);
        tau.set_size(ntau);
        if (b_A.size(0) > 0) {
          i = b_A.size(0);
          for (b_i = 0; b_i <= i - 2; b_i++) {
            double taui;
            int b_taui_tmp;
            int taui_tmp;
            e[b_i] = b_A[(b_i + b_A.size(0) * b_i) + 1];
            taui_tmp = n - b_i;
            b_taui_tmp = b_i * (n + 1);
            ntau = b_i + 3;
            loop_ub_tmp = n + 1;
            if (ntau <= loop_ub_tmp) {
              loop_ub_tmp = ntau;
            }
            taui = internal::reflapack::xzlarfg(taui_tmp, &e[b_i], b_A,
                                                b_taui_tmp + loop_ub_tmp);
            if (taui != 0.0) {
              double b_tau_tmp;
              double temp1;
              int i1;
              int tau_tmp;
              b_A[(b_i + b_A.size(0) * b_i) + 1] = 1.0;
              for (ntau = b_i + 1; ntau <= n; ntau++) {
                tau[ntau - 1] = 0.0;
              }
              for (int jj = 0; jj < taui_tmp; jj++) {
                loop_ub_tmp = b_i + jj;
                temp1 = taui * b_A[(loop_ub_tmp + b_A.size(0) * b_i) + 1];
                absx = 0.0;
                tau[loop_ub_tmp] =
                    tau[loop_ub_tmp] +
                    temp1 *
                        b_A[(loop_ub_tmp + b_A.size(0) * (loop_ub_tmp + 1)) +
                            1];
                i1 = jj + 2;
                for (int ii = i1; ii <= taui_tmp; ii++) {
                  tau_tmp = b_i + ii;
                  b_tau_tmp = b_A[tau_tmp + b_A.size(0) * (loop_ub_tmp + 1)];
                  tau[tau_tmp - 1] = tau[tau_tmp - 1] + temp1 * b_tau_tmp;
                  absx += b_tau_tmp * b_A[tau_tmp + b_A.size(0) * b_i];
                }
                tau[loop_ub_tmp] = tau[loop_ub_tmp] + taui * absx;
              }
              ntau = b_taui_tmp + b_i;
              absx = 0.0;
              if (taui_tmp >= 1) {
                for (loop_ub_tmp = 0; loop_ub_tmp < taui_tmp; loop_ub_tmp++) {
                  absx +=
                      tau[b_i + loop_ub_tmp] * b_A[(ntau + loop_ub_tmp) + 1];
                }
              }
              absx *= -0.5 * taui;
              if ((taui_tmp >= 1) && (!(absx == 0.0))) {
                i1 = taui_tmp - 1;
                for (loop_ub_tmp = 0; loop_ub_tmp <= i1; loop_ub_tmp++) {
                  tau_tmp = b_i + loop_ub_tmp;
                  tau[tau_tmp] =
                      tau[tau_tmp] + absx * b_A[(ntau + loop_ub_tmp) + 1];
                }
              }
              for (int jj = 0; jj < taui_tmp; jj++) {
                loop_ub_tmp = b_i + jj;
                temp1 = b_A[(loop_ub_tmp + b_A.size(0) * b_i) + 1];
                absx = tau[loop_ub_tmp];
                b_tau_tmp = absx * temp1;
                b_A[(loop_ub_tmp + b_A.size(0) * (loop_ub_tmp + 1)) + 1] =
                    (b_A[(loop_ub_tmp + b_A.size(0) * (loop_ub_tmp + 1)) + 1] -
                     b_tau_tmp) -
                    b_tau_tmp;
                i1 = jj + 2;
                for (int ii = i1; ii <= taui_tmp; ii++) {
                  ntau = b_i + ii;
                  b_A[ntau + b_A.size(0) * (loop_ub_tmp + 1)] =
                      (b_A[ntau + b_A.size(0) * (loop_ub_tmp + 1)] -
                       tau[ntau - 1] * temp1) -
                      b_A[ntau + b_A.size(0) * b_i] * absx;
                }
              }
            }
            b_A[(b_i + b_A.size(0) * b_i) + 1] = e[b_i];
            W[b_i] = b_A[b_i + b_A.size(0) * b_i];
            tau[b_i] = taui;
          }
          W[b_A.size(0) - 1] =
              b_A[(b_A.size(0) + b_A.size(0) * (b_A.size(0) - 1)) - 1];
        }
        n = b_A.size(0);
        if ((b_A.size(0) != 0) && (b_A.size(1) != 0)) {
          for (ntau = n; ntau >= 2; ntau--) {
            b_A[b_A.size(0) * (ntau - 1)] = 0.0;
            i = ntau + 1;
            for (b_i = i; b_i <= n; b_i++) {
              b_A[(b_i + b_A.size(0) * (ntau - 1)) - 1] =
                  b_A[(b_i + b_A.size(0) * (ntau - 2)) - 1];
            }
          }
          b_A[0] = 1.0;
          for (b_i = 2; b_i <= n; b_i++) {
            b_A[b_i - 1] = 0.0;
          }
          if (b_A.size(0) > 1) {
            internal::reflapack::xzungqr(b_A.size(0) - 1, b_A.size(0) - 1,
                                         b_A.size(0) - 1, b_A, b_A.size(0) + 2,
                                         b_A.size(0), tau);
          }
        }
        ntau = internal::reflapack::xzsteqr(W, e, b_A);
        if (ntau != 0) {
          ntau = W.size(0);
          W.set_size(ntau);
          for (i = 0; i < ntau; i++) {
            W[i] = rtNaN;
          }
          ntau = b_A.size(0);
          loop_ub_tmp = b_A.size(1);
          b_A.set_size(ntau, loop_ub_tmp);
          ntau *= loop_ub_tmp;
          for (i = 0; i < ntau; i++) {
            b_A[i] = rtNaN;
          }
        } else if (iscale) {
          absx = 1.0 / anrm;
          i = A.size(0);
          for (loop_ub_tmp = 0; loop_ub_tmp < i; loop_ub_tmp++) {
            W[loop_ub_tmp] = absx * W[loop_ub_tmp];
          }
        }
      }
    }
  }
  D.set_size(W.size(0));
  ntau = W.size(0);
  for (i = 0; i < ntau; i++) {
    D[i].re = W[i];
    D[i].im = 0.0;
  }
  V.set_size(b_A.size(0), b_A.size(1));
  ntau = b_A.size(0) * b_A.size(1);
  for (i = 0; i < ntau; i++) {
    V[i].re = b_A[i];
    V[i].im = 0.0;
  }
}

} // namespace coder

// End of code generation (eigHermitianStandard.cpp)
