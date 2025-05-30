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
#include "eof_rtwutil.h"
#include "rt_nonfinite.h"
#include "xdhseqr.h"
#include "xnrm2.h"
#include "xzlarf.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void eigHermitianStandard(const ::coder::array<double, 2U> &A,
                          ::coder::array<double, 2U> &V,
                          ::coder::array<double, 1U> &D)
{
  array<double, 2U> b_A;
  array<double, 1U> tau;
  array<double, 1U> work;
  int k;
  int n;
  int nx;
  bool p;
  nx = A.size(0) * A.size(1);
  p = true;
  for (k = 0; k < nx; k++) {
    if ((!p) || (std::isinf(A[k]) || std::isnan(A[k]))) {
      p = false;
    }
  }
  if (!p) {
    int i;
    int ix0;
    ix0 = A.size(0);
    V.set_size(A.size(0), A.size(1));
    nx = A.size(0) * A.size(1);
    for (i = 0; i < nx; i++) {
      V[i] = rtNaN;
    }
    if ((A.size(0) != 0) && (A.size(1) != 0) && (1 < A.size(0))) {
      int itau;
      int nh;
      itau = 2;
      if (A.size(0) - 2 < A.size(1) - 1) {
        nh = A.size(0) - 1;
      } else {
        nh = A.size(1);
      }
      for (int j{0}; j < nh; j++) {
        for (int b_i{itau}; b_i <= ix0; b_i++) {
          V[(b_i + V.size(0) * j) - 1] = 0.0;
        }
        itau++;
      }
    }
    b_A.set_size(A.size(0), A.size(1));
    nx = A.size(0) * A.size(1);
    for (i = 0; i < nx; i++) {
      b_A[i] = rtNaN;
    }
  } else {
    int b_i;
    int b_n;
    int i;
    int i1;
    int ia;
    int itau;
    int ix0;
    int j;
    int nh;
    n = A.size(0);
    b_A.set_size(A.size(0), A.size(1));
    nx = A.size(0) * A.size(1);
    for (i = 0; i < nx; i++) {
      b_A[i] = A[i];
    }
    b_n = A.size(0);
    if (A.size(0) < 1) {
      i = 0;
    } else {
      i = A.size(0) - 1;
    }
    tau.set_size(i);
    work.set_size(A.size(0));
    nx = A.size(0);
    for (i = 0; i < nx; i++) {
      work[i] = 0.0;
    }
    i = A.size(0);
    for (b_i = 0; b_i <= i - 2; b_i++) {
      double alpha1;
      double temp;
      int in;
      int iv0_tmp;
      int lastc;
      int lastv;
      int n_tmp_tmp;
      nh = b_i * b_n;
      in = (b_i + 1) * b_n;
      alpha1 = b_A[(b_i + b_A.size(0) * b_i) + 1];
      nx = b_i + 3;
      if (nx >= b_n) {
        nx = b_n;
      }
      ix0 = nx + nh;
      n_tmp_tmp = b_n - b_i;
      tau[b_i] = 0.0;
      if (n_tmp_tmp - 1 > 0) {
        temp = internal::blas::xnrm2(n_tmp_tmp - 2, b_A, ix0);
        if (temp != 0.0) {
          double beta1;
          beta1 = rt_hypotd_snf(alpha1, temp);
          if (alpha1 >= 0.0) {
            beta1 = -beta1;
          }
          if (std::abs(beta1) < 1.0020841800044864E-292) {
            nx = 0;
            i1 = (ix0 + n_tmp_tmp) - 3;
            do {
              nx++;
              for (k = ix0; k <= i1; k++) {
                b_A[k - 1] = 9.9792015476736E+291 * b_A[k - 1];
              }
              beta1 *= 9.9792015476736E+291;
              alpha1 *= 9.9792015476736E+291;
            } while ((std::abs(beta1) < 1.0020841800044864E-292) && (nx < 20));
            beta1 = rt_hypotd_snf(
                alpha1, internal::blas::xnrm2(n_tmp_tmp - 2, b_A, ix0));
            if (alpha1 >= 0.0) {
              beta1 = -beta1;
            }
            tau[b_i] = (beta1 - alpha1) / beta1;
            temp = 1.0 / (alpha1 - beta1);
            for (k = ix0; k <= i1; k++) {
              b_A[k - 1] = temp * b_A[k - 1];
            }
            for (k = 0; k < nx; k++) {
              beta1 *= 1.0020841800044864E-292;
            }
            alpha1 = beta1;
          } else {
            tau[b_i] = (beta1 - alpha1) / beta1;
            temp = 1.0 / (alpha1 - beta1);
            i1 = (ix0 + n_tmp_tmp) - 3;
            for (k = ix0; k <= i1; k++) {
              b_A[k - 1] = temp * b_A[k - 1];
            }
            alpha1 = beta1;
          }
        }
      }
      b_A[(b_i + b_A.size(0) * b_i) + 1] = 1.0;
      iv0_tmp = b_i + nh;
      nh = in + 1;
      if (tau[b_i] != 0.0) {
        bool exitg2;
        lastv = n_tmp_tmp - 2;
        nx = (iv0_tmp + n_tmp_tmp) - 2;
        while ((lastv + 1 > 0) && (b_A[nx + 1] == 0.0)) {
          lastv--;
          nx--;
        }
        lastc = b_n;
        exitg2 = false;
        while ((!exitg2) && (lastc > 0)) {
          int exitg1;
          nx = in + lastc;
          ia = nx;
          do {
            exitg1 = 0;
            if ((b_n > 0) && (ia <= nx + lastv * b_n)) {
              if (b_A[ia - 1] != 0.0) {
                exitg1 = 1;
              } else {
                ia += b_n;
              }
            } else {
              lastc--;
              exitg1 = 2;
            }
          } while (exitg1 == 0);
          if (exitg1 == 1) {
            exitg2 = true;
          }
        }
      } else {
        lastv = -1;
        lastc = 0;
      }
      if (lastv + 1 > 0) {
        if (lastc != 0) {
          for (nx = 0; nx < lastc; nx++) {
            work[nx] = 0.0;
          }
          nx = iv0_tmp + 1;
          i1 = (in + b_n * lastv) + 1;
          for (ix0 = nh; b_n < 0 ? ix0 >= i1 : ix0 <= i1; ix0 += b_n) {
            k = (ix0 + lastc) - 1;
            for (ia = ix0; ia <= k; ia++) {
              itau = ia - ix0;
              work[itau] = work[itau] + b_A[ia - 1] * b_A[nx];
            }
            nx++;
          }
        }
        if (!(-tau[b_i] == 0.0)) {
          nx = in;
          for (j = 0; j <= lastv; j++) {
            i1 = (iv0_tmp + j) + 1;
            if (b_A[i1] != 0.0) {
              temp = b_A[i1] * -tau[b_i];
              i1 = nx + 1;
              k = lastc + nx;
              for (itau = i1; itau <= k; itau++) {
                b_A[itau - 1] = b_A[itau - 1] + work[(itau - nx) - 1] * temp;
              }
            }
            nx += b_n;
          }
        }
      }
      internal::reflapack::xzlarf(n_tmp_tmp - 1, n_tmp_tmp - 1, iv0_tmp + 2,
                                  tau[b_i], b_A, (b_i + in) + 2, b_n, work);
      b_A[(b_i + b_A.size(0) * b_i) + 1] = alpha1;
    }
    V.set_size(b_A.size(0), b_A.size(1));
    nx = b_A.size(0) * b_A.size(1);
    for (i = 0; i < nx; i++) {
      V[i] = b_A[i];
    }
    if (A.size(0) != 0) {
      nh = A.size(0) - 1;
      for (j = n; j >= 2; j--) {
        ia = (j - 1) * n - 1;
        for (b_i = 0; b_i <= j - 2; b_i++) {
          V[(ia + b_i) + 1] = 0.0;
        }
        nx = ia - n;
        i = j + 1;
        for (b_i = i; b_i <= n; b_i++) {
          V[ia + b_i] = V[nx + b_i];
        }
        i = n + 1;
        for (b_i = i; b_i <= n; b_i++) {
          V[ia + b_i] = 0.0;
        }
      }
      for (b_i = 0; b_i < n; b_i++) {
        V[b_i] = 0.0;
      }
      V[0] = 1.0;
      i = A.size(0) + 1;
      for (j = i; j <= n; j++) {
        ia = (j - 1) * n;
        for (b_i = 0; b_i < n; b_i++) {
          V[ia + b_i] = 0.0;
        }
        V[(ia + j) - 1] = 1.0;
      }
      if (A.size(0) - 1 >= 1) {
        i = A.size(0) - 2;
        for (j = nh; j <= i; j++) {
          ia = (n + j * n) + 1;
          i1 = n - 2;
          for (b_i = 0; b_i <= i1; b_i++) {
            V[ia + b_i] = 0.0;
          }
          V[ia + j] = 1.0;
        }
        itau = A.size(0) - 2;
        work.set_size(V.size(1));
        nx = V.size(1);
        for (i = 0; i < nx; i++) {
          work[i] = 0.0;
        }
        for (b_i = A.size(0) - 1; b_i >= 1; b_i--) {
          nx = (n + b_i) + (b_i - 1) * n;
          if (b_i < n - 1) {
            V[nx] = 1.0;
            i = nx + n;
            internal::reflapack::xzlarf(n - b_i, nh - b_i, nx + 1, tau[itau], V,
                                        i + 1, n, work);
            ix0 = nx + 2;
            i -= b_i;
            for (k = ix0; k <= i; k++) {
              V[k - 1] = -tau[itau] * V[k - 1];
            }
          }
          V[nx] = 1.0 - tau[itau];
          for (j = 0; j <= b_i - 2; j++) {
            V[(nx - j) - 1] = 0.0;
          }
          itau--;
        }
      }
    }
    internal::reflapack::eml_dlahqr(b_A, V);
    nx = b_A.size(0);
    if ((b_A.size(0) != 0) && (b_A.size(1) != 0) && (3 < b_A.size(0))) {
      itau = 4;
      if (b_A.size(0) - 4 < b_A.size(1) - 1) {
        nh = b_A.size(0) - 3;
      } else {
        nh = b_A.size(1);
      }
      for (j = 0; j < nh; j++) {
        for (b_i = itau; b_i <= nx; b_i++) {
          b_A[(b_i + b_A.size(0) * j) - 1] = 0.0;
        }
        itau++;
      }
    }
  }
  n = b_A.size(0);
  D.set_size(b_A.size(0));
  for (k = 0; k < n; k++) {
    D[k] = b_A[k + b_A.size(0) * k];
  }
}

} // namespace coder

// End of code generation (eigHermitianStandard.cpp)
