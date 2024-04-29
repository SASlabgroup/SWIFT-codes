//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// eig.cpp
//
// Code generation for function 'eig'
//

// Include files
#include "eig.h"
#include "eigStandard.h"
#include "processSIGburst_onboard_data.h"
#include "rt_nonfinite.h"
#include "xdlahqr.h"
#include "xzgehrd.h"
#include "xzlarf.h"
#include "xzlarfg.h"
#include "xzlascl.h"
#include "xzsteqr.h"
#include "xzunghr.h"
#include <algorithm>
#include <cmath>
#include <cstring>

// Function Definitions
namespace coder {
void eig(const double A[16384], creal_T V[16384], creal_T D[128])
{
  static double Q[16384];
  static double b_A[16384];
  double work[128];
  double e[127];
  double absx;
  int k;
  bool iscale;
  iscale = true;
  for (k = 0; k < 16384; k++) {
    if (iscale) {
      absx = A[k];
      if (std::isinf(absx) || std::isnan(absx)) {
        iscale = false;
      }
    } else {
      iscale = false;
    }
  }
  if (!iscale) {
    for (int i{0}; i < 16384; i++) {
      V[i].re = rtNaN;
      V[i].im = 0.0;
    }
    for (int b_i{0}; b_i < 128; b_i++) {
      D[b_i].re = rtNaN;
      D[b_i].im = 0.0;
    }
  } else {
    int b_i;
    int exitg1;
    bool exitg2;
    iscale = true;
    k = 0;
    exitg2 = false;
    while ((!exitg2) && (k < 128)) {
      b_i = 0;
      do {
        exitg1 = 0;
        if (b_i <= k) {
          if (!(A[b_i + (k << 7)] == A[k + (b_i << 7)])) {
            iscale = false;
            exitg1 = 1;
          } else {
            b_i++;
          }
        } else {
          k++;
          exitg1 = 2;
        }
      } while (exitg1 == 0);
      if (exitg1 == 1) {
        exitg2 = true;
      }
    }
    if (iscale) {
      double a__4[128];
      double anrm;
      int i;
      std::copy(&A[0], &A[16384], &b_A[0]);
      anrm = 0.0;
      k = 0;
      exitg2 = false;
      while ((!exitg2) && (k < 128)) {
        b_i = 0;
        do {
          exitg1 = 0;
          if (b_i <= k) {
            absx = std::abs(A[b_i + (k << 7)]);
            if (std::isnan(absx)) {
              anrm = rtNaN;
              exitg1 = 1;
            } else {
              if (absx > anrm) {
                anrm = absx;
              }
              b_i++;
            }
          } else {
            k++;
            exitg1 = 2;
          }
        } while (exitg1 == 0);
        if (exitg1 == 1) {
          exitg2 = true;
        }
      }
      if (std::isinf(anrm) || std::isnan(anrm)) {
        for (b_i = 0; b_i < 128; b_i++) {
          a__4[b_i] = rtNaN;
        }
        for (i = 0; i < 16384; i++) {
          b_A[i] = rtNaN;
        }
      } else {
        double tau[127];
        double temp2;
        int iaii;
        int sgn;
        iscale = false;
        if ((anrm > 0.0) && (anrm < 1.0010415475915505E-146)) {
          iscale = true;
          anrm = 1.0010415475915505E-146 / anrm;
          internal::reflapack::xzlascl(1.0, anrm, b_A);
        } else if (anrm > 9.9895953610111751E+145) {
          iscale = true;
          anrm = 9.9895953610111751E+145 / anrm;
          internal::reflapack::xzlascl(1.0, anrm, b_A);
        }
        for (b_i = 0; b_i < 127; b_i++) {
          double taui;
          int e_tmp_tmp;
          int ia0_tmp_tmp;
          ia0_tmp_tmp = b_i << 7;
          e_tmp_tmp = b_i + ia0_tmp_tmp;
          e[b_i] = b_A[e_tmp_tmp + 1];
          sgn = b_i + 3;
          if (sgn > 128) {
            sgn = 128;
          }
          taui = internal::reflapack::xzlarfg(127 - b_i, e[b_i], b_A,
                                              ia0_tmp_tmp + sgn);
          if (taui != 0.0) {
            double temp1;
            int i1;
            int i2;
            int tau_tmp;
            b_A[e_tmp_tmp + 1] = 1.0;
            for (sgn = b_i + 1; sgn < 128; sgn++) {
              tau[sgn - 1] = 0.0;
            }
            i = 126 - b_i;
            i1 = 127 - b_i;
            for (int jj{0}; jj <= i; jj++) {
              iaii = b_i + jj;
              temp1 = taui * b_A[(iaii + ia0_tmp_tmp) + 1];
              temp2 = 0.0;
              tau_tmp = (iaii + 1) << 7;
              tau[iaii] += temp1 * b_A[(iaii + tau_tmp) + 1];
              i2 = jj + 2;
              for (int ii{i2}; ii <= i1; ii++) {
                sgn = b_i + ii;
                absx = b_A[sgn + tau_tmp];
                tau[sgn - 1] += temp1 * absx;
                temp2 += absx * b_A[sgn + ia0_tmp_tmp];
              }
              tau[iaii] += taui * temp2;
            }
            temp2 = 0.0;
            for (k = 0; k <= i; k++) {
              temp2 += tau[b_i + k] * b_A[(e_tmp_tmp + k) + 1];
            }
            temp2 *= -0.5 * taui;
            if (!(temp2 == 0.0)) {
              for (k = 0; k <= i; k++) {
                tau_tmp = b_i + k;
                tau[tau_tmp] += temp2 * b_A[(e_tmp_tmp + k) + 1];
              }
            }
            for (int jj{0}; jj <= i; jj++) {
              iaii = b_i + jj;
              temp1 = b_A[(iaii + ia0_tmp_tmp) + 1];
              absx = tau[iaii];
              temp2 = absx * temp1;
              k = (iaii + 1) << 7;
              iaii = (iaii + k) + 1;
              b_A[iaii] = (b_A[iaii] - temp2) - temp2;
              i2 = jj + 2;
              for (int ii{i2}; ii <= i1; ii++) {
                iaii = b_i + ii;
                sgn = iaii + k;
                b_A[sgn] = (b_A[sgn] - tau[iaii - 1] * temp1) -
                           b_A[iaii + ia0_tmp_tmp] * absx;
              }
            }
          }
          b_A[e_tmp_tmp + 1] = e[b_i];
          a__4[b_i] = b_A[e_tmp_tmp];
          tau[b_i] = taui;
        }
        a__4[127] = b_A[16383];
        for (k = 126; k >= 0; k--) {
          iaii = (k + 1) << 7;
          b_A[iaii] = 0.0;
          i = k + 3;
          for (b_i = i; b_i < 129; b_i++) {
            b_A[(b_i + iaii) - 1] = b_A[(b_i + (k << 7)) - 1];
          }
        }
        b_A[0] = 1.0;
        std::memset(&b_A[1], 0, 127U * sizeof(double));
        std::memset(&work[0], 0, 128U * sizeof(double));
        for (b_i = 126; b_i >= 0; b_i--) {
          iaii = (b_i + (b_i << 7)) + 129;
          if (b_i + 1 < 127) {
            b_A[iaii] = 1.0;
            internal::reflapack::xzlarf(127 - b_i, 126 - b_i, iaii + 1,
                                        tau[b_i], b_A, iaii + 129, work);
            sgn = iaii + 2;
            i = (iaii - b_i) + 127;
            for (k = sgn; k <= i; k++) {
              b_A[k - 1] *= -tau[b_i];
            }
          }
          b_A[iaii] = 1.0 - tau[b_i];
          for (k = 0; k < b_i; k++) {
            b_A[(iaii - k) - 1] = 0.0;
          }
        }
        sgn = internal::reflapack::xzsteqr(a__4, e, b_A);
        if (sgn != 0) {
          for (b_i = 0; b_i < 128; b_i++) {
            a__4[b_i] = rtNaN;
          }
          for (i = 0; i < 16384; i++) {
            b_A[i] = rtNaN;
          }
        } else if (iscale) {
          temp2 = 1.0 / anrm;
          for (k = 0; k < 128; k++) {
            a__4[k] *= temp2;
          }
        }
      }
      for (b_i = 0; b_i < 128; b_i++) {
        D[b_i].re = a__4[b_i];
        D[b_i].im = 0.0;
      }
      for (i = 0; i < 16384; i++) {
        V[i].re = b_A[i];
        V[i].im = 0.0;
      }
    } else {
      iscale = true;
      k = 0;
      exitg2 = false;
      while ((!exitg2) && (k < 128)) {
        b_i = 0;
        do {
          exitg1 = 0;
          if (b_i <= k) {
            if (!(A[b_i + (k << 7)] == -A[k + (b_i << 7)])) {
              iscale = false;
              exitg1 = 1;
            } else {
              b_i++;
            }
          } else {
            k++;
            exitg1 = 2;
          }
        } while (exitg1 == 0);
        if (exitg1 == 1) {
          exitg2 = true;
        }
      }
      if (iscale) {
        double a__4[128];
        double tau[127];
        int i;
        int sgn;
        std::copy(&A[0], &A[16384], &b_A[0]);
        internal::reflapack::xzgehrd(b_A, 1, 128, tau);
        std::copy(&b_A[0], &b_A[16384], &Q[0]);
        internal::reflapack::xzunghr(1, 128, Q, tau);
        sgn = internal::reflapack::xdlahqr(1, 128, b_A, 1, 128, Q, a__4, work);
        i = static_cast<unsigned char>(sgn);
        for (b_i = 0; b_i < i; b_i++) {
          D[b_i].re = rtNaN;
          D[b_i].im = 0.0;
        }
        i = sgn + 1;
        for (b_i = i; b_i < 129; b_i++) {
          D[b_i - 1].re = 0.0;
          D[b_i - 1].im = work[b_i - 1];
        }
        if (sgn == 0) {
          for (i = 0; i < 16384; i++) {
            V[i].re = Q[i];
            V[i].im = 0.0;
          }
          k = 1;
          do {
            exitg1 = 0;
            if (k <= 128) {
              if (k != 128) {
                i = (k - 1) << 7;
                absx = b_A[k + i];
                if (absx != 0.0) {
                  if (absx < 0.0) {
                    sgn = 1;
                  } else {
                    sgn = -1;
                  }
                  for (b_i = 0; b_i < 128; b_i++) {
                    double temp2;
                    int i1;
                    int i2;
                    i1 = b_i + i;
                    absx = V[i1].re;
                    i2 = b_i + (k << 7);
                    temp2 = static_cast<double>(sgn) * V[i2].re;
                    if (temp2 == 0.0) {
                      V[i1].re = absx / 1.4142135623730951;
                      V[i1].im = 0.0;
                    } else if (absx == 0.0) {
                      V[i1].re = 0.0;
                      V[i1].im = temp2 / 1.4142135623730951;
                    } else {
                      V[i1].re = absx / 1.4142135623730951;
                      V[i1].im = temp2 / 1.4142135623730951;
                    }
                    V[i2].re = V[i1].re;
                    V[i2].im = -V[i1].im;
                  }
                  k += 2;
                } else {
                  k++;
                }
              } else {
                k++;
              }
            } else {
              exitg1 = 1;
            }
          } while (exitg1 == 0);
        } else {
          for (i = 0; i < 16384; i++) {
            V[i].re = rtNaN;
            V[i].im = 0.0;
          }
        }
      } else {
        eigStandard(A, V, D);
      }
    }
  }
}

} // namespace coder

// End of code generation (eig.cpp)
