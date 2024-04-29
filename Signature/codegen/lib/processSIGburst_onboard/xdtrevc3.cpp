//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdtrevc3.cpp
//
// Code generation for function 'xdtrevc3'
//

// Include files
#include "xdtrevc3.h"
#include "rt_nonfinite.h"
#include "xaxpy.h"
#include "xdlaln2.h"
#include "xgemv.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xdtrevc3(const ::coder::array<double, 2U> &T,
              ::coder::array<double, 2U> &vr)
{
  array<double, 2U> work;
  double x[4];
  double bignum;
  double emax;
  double smlnum;
  int i;
  int ii;
  int ip;
  int j;
  int n;
  int n2;
  int np1;
  n = T.size(0);
  smlnum = 2.2250738585072014E-308 *
           (static_cast<double>(T.size(0)) / 2.2204460492503131E-16);
  bignum = 0.99999999999999978 / smlnum;
  work.set_size(T.size(0), 3);
  ii = T.size(0) * 3;
  for (i = 0; i < ii; i++) {
    work[i] = 0.0;
  }
  x[0] = 0.0;
  x[1] = 0.0;
  x[2] = 0.0;
  x[3] = 0.0;
  work[0] = 0.0;
  for (j = 2; j <= n; j++) {
    work[j - 1] = 0.0;
    for (ii = 0; ii <= j - 2; ii++) {
      work[j - 1] = work[j - 1] + std::abs(T[ii + T.size(0) * (j - 1)]);
    }
  }
  n2 = (T.size(0) << 1) + 1;
  np1 = T.size(0) + 1;
  ip = 0;
  for (int ki{n}; ki >= 1; ki--) {
    if (ip == -1) {
      ip = 1;
    } else {
      double smin;
      double wi;
      double wr;
      if ((ki == 1) || (T[(ki + T.size(0) * (ki - 2)) - 1] == 0.0)) {
        ip = 0;
      } else {
        ip = -1;
      }
      wr = T[(ki + T.size(0) * (ki - 1)) - 1];
      wi = 0.0;
      if (ip != 0) {
        wi = std::sqrt(std::abs(T[(ki + T.size(0) * (ki - 2)) - 1])) *
             std::sqrt(std::abs(T[(ki + T.size(0) * (ki - 1)) - 2]));
      }
      smin = std::fmax(2.2204460492503131E-16 * (std::abs(wr) + wi), smlnum);
      if (ip == 0) {
        double scale;
        work[(ki + work.size(0) * 2) - 1] = 1.0;
        for (int k{0}; k <= ki - 2; k++) {
          work[k + work.size(0) * 2] = -T[k + T.size(0) * (ki - 1)];
        }
        j = ki - 2;
        while (j + 1 >= 1) {
          if ((j + 1 == 1) || (T[j + T.size(0) * (j - 1)] == 0.0)) {
            i = j * n;
            scale = xdlaln2(1, 1, smin, T, (i + j) + 1, n, work, j + n2, n, wr,
                            0.0, x, emax);
            if ((emax > 1.0) && (work[j] > bignum / emax)) {
              x[0] /= emax;
              scale /= emax;
            }
            if (scale != 1.0) {
              ii = n2 + ki;
              for (int k{n2}; k < ii; k++) {
                work[k - 1] = scale * work[k - 1];
              }
            }
            work[j + work.size(0) * 2] = x[0];
            blas::xaxpy(j, -x[0], T, i + 1, work, n2);
            j--;
          } else {
            i = (j - 1) * n;
            scale = xdlaln2(2, 1, smin, T, i + j, n, work, (n2 + j) - 1, n, wr,
                            0.0, x, emax);
            if ((emax > 1.0) &&
                (std::fmax(work[j - 1], work[j]) > bignum / emax)) {
              x[0] /= emax;
              x[1] /= emax;
              scale /= emax;
            }
            if (scale != 1.0) {
              ii = n2 + ki;
              for (int k{n2}; k < ii; k++) {
                work[k - 1] = scale * work[k - 1];
              }
            }
            work[(j + work.size(0) * 2) - 1] = x[0];
            work[j + work.size(0) * 2] = x[1];
            blas::xaxpy(j - 1, -x[0], T, i + 1, work, n2);
            blas::xaxpy(j - 1, -x[1], T, j * n + 1, work, n2);
            j -= 2;
          }
        }
        if (ki > 1) {
          blas::xgemv(n, ki - 1, n, work, n2, work[(ki + work.size(0) * 2) - 1],
                      vr, (ki - 1) * n + 1);
        }
        j = (ki - 1) * n;
        if (n < 1) {
          ii = 0;
        } else {
          ii = 1;
          if (n > 1) {
            emax = std::abs(vr[j]);
            for (int k{2}; k <= n; k++) {
              scale = std::abs(vr[(j + k) - 1]);
              if (scale > emax) {
                ii = k;
                emax = scale;
              }
            }
          }
        }
        emax = 1.0 / std::abs(vr[(ii + vr.size(0) * (ki - 1)) - 1]);
        i = j + n;
        for (int k{j + 1}; k <= i; k++) {
          vr[k - 1] = emax * vr[k - 1];
        }
      } else {
        double scale;
        emax = T[(ki + T.size(0) * (ki - 1)) - 2];
        scale = T[(ki + T.size(0) * (ki - 2)) - 1];
        if (std::abs(emax) >= std::abs(scale)) {
          work[(ki + work.size(0)) - 2] = 1.0;
          work[(ki + work.size(0) * 2) - 1] = wi / emax;
        } else {
          work[(ki + work.size(0)) - 2] = -wi / scale;
          work[(ki + work.size(0) * 2) - 1] = 1.0;
        }
        work[(ki + work.size(0)) - 1] = 0.0;
        work[(ki + work.size(0) * 2) - 2] = 0.0;
        for (int k{0}; k <= ki - 3; k++) {
          work[k + work.size(0)] =
              -work[(ki + work.size(0)) - 2] * T[k + T.size(0) * (ki - 2)];
          work[k + work.size(0) * 2] =
              -work[(ki + work.size(0) * 2) - 1] * T[k + T.size(0) * (ki - 1)];
        }
        j = ki - 3;
        while (j + 1 >= 1) {
          if ((j + 1 == 1) || (T[j + T.size(0) * (j - 1)] == 0.0)) {
            i = j * n;
            scale = xdlaln2(1, 2, smin, T, (i + j) + 1, n, work, (j + n) + 1, n,
                            wr, wi, x, emax);
            if ((emax > 1.0) && (work[j] > bignum / emax)) {
              x[0] /= emax;
              x[2] /= emax;
              scale /= emax;
            }
            if (scale != 1.0) {
              ii = n + ki;
              for (int k{np1}; k <= ii; k++) {
                work[k - 1] = scale * work[k - 1];
              }
              ii = n2 + ki;
              for (int k{n2}; k < ii; k++) {
                work[k - 1] = scale * work[k - 1];
              }
            }
            work[j + work.size(0)] = x[0];
            work[j + work.size(0) * 2] = x[2];
            blas::xaxpy(j, -x[0], T, i + 1, work, n + 1);
            blas::xaxpy(j, -x[2], T, i + 1, work, n2);
            j--;
          } else {
            i = (j - 1) * n;
            scale = xdlaln2(2, 2, smin, T, i + j, n, work, j + n, n, wr, wi, x,
                            emax);
            if ((emax > 1.0) &&
                (std::fmax(work[j - 1], work[j]) > bignum / emax)) {
              emax = 1.0 / emax;
              x[0] *= emax;
              x[2] *= emax;
              x[1] *= emax;
              x[3] *= emax;
              scale *= emax;
            }
            if (scale != 1.0) {
              ii = n + ki;
              for (int k{np1}; k <= ii; k++) {
                work[k - 1] = scale * work[k - 1];
              }
              ii = n2 + ki;
              for (int k{n2}; k < ii; k++) {
                work[k - 1] = scale * work[k - 1];
              }
            }
            work[(j + work.size(0)) - 1] = x[0];
            work[j + work.size(0)] = x[1];
            work[(j + work.size(0) * 2) - 1] = x[2];
            work[j + work.size(0) * 2] = x[3];
            blas::xaxpy(j - 1, -x[0], T, i + 1, work, n + 1);
            ii = j * n + 1;
            blas::xaxpy(j - 1, -x[1], T, ii, work, n + 1);
            blas::xaxpy(j - 1, -x[2], T, i + 1, work, n2);
            blas::xaxpy(j - 1, -x[3], T, ii, work, n2);
            j -= 2;
          }
        }
        if (ki > 2) {
          blas::xgemv(n, ki - 2, n, work, n + 1, work[(ki + work.size(0)) - 2],
                      vr, (ki - 2) * n + 1);
          blas::xgemv(n, ki - 2, n, work, n2, work[(ki + work.size(0) * 2) - 1],
                      vr, (ki - 1) * n + 1);
        } else {
          emax = work[work.size(0)];
          ii = (ki - 2) * n;
          i = ii + n;
          for (int k{ii + 1}; k <= i; k++) {
            vr[k - 1] = emax * vr[k - 1];
          }
          emax = work[(ki + work.size(0) * 2) - 1];
          ii = (ki - 1) * n;
          i = ii + n;
          for (int k{ii + 1}; k <= i; k++) {
            vr[k - 1] = emax * vr[k - 1];
          }
        }
        emax = 0.0;
        for (int k{0}; k < n; k++) {
          emax = std::fmax(emax, std::abs(vr[k + vr.size(0) * (ki - 2)]) +
                                     std::abs(vr[k + vr.size(0) * (ki - 1)]));
        }
        emax = 1.0 / emax;
        ii = (ki - 2) * n;
        i = ii + n;
        for (int k{ii + 1}; k <= i; k++) {
          vr[k - 1] = emax * vr[k - 1];
        }
        ii = (ki - 1) * n;
        i = ii + n;
        for (int k{ii + 1}; k <= i; k++) {
          vr[k - 1] = emax * vr[k - 1];
        }
      }
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdtrevc3.cpp)
