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
#include <cmath>
#include <cstring>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xdtrevc3(const double T[16384], double vr[16384])
{
  double work[384];
  double x[4];
  double emax;
  int ip;
  int iyend;
  int j;
  std::memset(&work[0], 0, 384U * sizeof(double));
  x[0] = 0.0;
  x[1] = 0.0;
  x[2] = 0.0;
  x[3] = 0.0;
  work[0] = 0.0;
  for (j = 0; j < 127; j++) {
    work[j + 1] = 0.0;
    for (iyend = 0; iyend <= j; iyend++) {
      work[j + 1] += std::abs(T[iyend + ((j + 1) << 7)]);
    }
  }
  ip = 0;
  for (int ki{127}; ki >= 0; ki--) {
    if (ip == -1) {
      ip = 1;
    } else {
      double smin;
      double wi;
      double wr_tmp;
      int wr_tmp_tmp;
      if ((ki + 1 == 1) || (T[ki + ((ki - 1) << 7)] == 0.0)) {
        ip = 0;
      } else {
        ip = -1;
      }
      wr_tmp_tmp = ki << 7;
      iyend = ki + wr_tmp_tmp;
      wr_tmp = T[iyend];
      wi = 0.0;
      if (ip != 0) {
        wi = std::sqrt(std::abs(T[ki + ((ki - 1) << 7)])) *
             std::sqrt(std::abs(T[iyend - 1]));
      }
      smin = std::fmax(2.2204460492503131E-16 * (std::abs(wr_tmp) + wi),
                       1.2826677504057426E-290);
      if (ip == 0) {
        double scale;
        int i;
        work[ki + 256] = 1.0;
        for (int k{0}; k < ki; k++) {
          work[k + 256] = -T[k + wr_tmp_tmp];
        }
        j = ki - 1;
        int exitg1;
        do {
          exitg1 = 0;
          if (j + 1 >= 1) {
            int i1;
            bool guard1;
            guard1 = false;
            if (j + 1 == 1) {
              guard1 = true;
            } else {
              i = (j - 1) << 7;
              i1 = j + i;
              if (T[i1] == 0.0) {
                guard1 = true;
              } else {
                scale = xdlaln2(2, 1, smin, T, i1, work, j + 256, wr_tmp, 0.0,
                                x, emax);
                if ((emax > 1.0) && (std::fmax(work[j - 1], work[j]) >
                                     7.7962512091199975E+289 / emax)) {
                  x[0] /= emax;
                  x[1] /= emax;
                  scale /= emax;
                }
                if (scale != 1.0) {
                  i1 = ki + 257;
                  for (int k{257}; k <= i1; k++) {
                    work[k - 1] *= scale;
                  }
                }
                work[j + 255] = x[0];
                work[j + 256] = x[1];
                blas::xaxpy(j - 1, -x[0], T, i + 1, work);
                blas::xaxpy(j - 1, -x[1], T, (j << 7) + 1, work);
                j -= 2;
              }
            }
            if (guard1) {
              i = j << 7;
              scale = xdlaln2(1, 1, smin, T, (i + j) + 1, work, j + 257, wr_tmp,
                              0.0, x, emax);
              if ((emax > 1.0) && (work[j] > 7.7962512091199975E+289 / emax)) {
                x[0] /= emax;
                scale /= emax;
              }
              if (scale != 1.0) {
                i1 = ki + 257;
                for (int k{257}; k <= i1; k++) {
                  work[k - 1] *= scale;
                }
              }
              work[j + 256] = x[0];
              blas::xaxpy(j, -x[0], T, i + 1, work);
              j--;
            }
          } else {
            exitg1 = 1;
          }
        } while (exitg1 == 0);
        if (ki + 1 > 1) {
          blas::xgemv(ki, work, work[ki + 256], vr, wr_tmp_tmp + 1);
        }
        iyend = -1;
        emax = std::abs(vr[wr_tmp_tmp]);
        for (int k{0}; k < 127; k++) {
          scale = std::abs(vr[(wr_tmp_tmp + k) + 1]);
          if (scale > emax) {
            iyend = k;
            emax = scale;
          }
        }
        emax = 1.0 / std::abs(vr[(iyend + wr_tmp_tmp) + 1]);
        i = wr_tmp_tmp + 128;
        for (int k{wr_tmp_tmp + 1}; k <= i; k++) {
          vr[k - 1] *= emax;
        }
      } else {
        double scale;
        int i;
        int i1;
        int ix;
        int ix0;
        emax = T[iyend - 1];
        ix0 = (ki - 1) << 7;
        scale = T[ki + ix0];
        if (std::abs(emax) >= std::abs(scale)) {
          work[ki + 127] = 1.0;
          work[ki + 256] = wi / emax;
        } else {
          work[ki + 127] = -wi / scale;
          work[ki + 256] = 1.0;
        }
        work[ki + 128] = 0.0;
        work[ki + 255] = 0.0;
        for (int k{0}; k <= ki - 2; k++) {
          work[k + 128] = -work[ki + 127] * T[k + ix0];
          work[k + 256] = -work[ki + 256] * T[k + wr_tmp_tmp];
        }
        j = ki - 2;
        int exitg1;
        do {
          exitg1 = 0;
          if (j + 1 >= 1) {
            bool guard1;
            guard1 = false;
            if (j + 1 == 1) {
              guard1 = true;
            } else {
              i = (j - 1) << 7;
              i1 = j + i;
              if (T[i1] == 0.0) {
                guard1 = true;
              } else {
                scale = xdlaln2(2, 2, smin, T, i1, work, j + 128, wr_tmp, wi, x,
                                emax);
                if ((emax > 1.0) && (std::fmax(work[j - 1], work[j]) >
                                     7.7962512091199975E+289 / emax)) {
                  emax = 1.0 / emax;
                  x[0] *= emax;
                  x[2] *= emax;
                  x[1] *= emax;
                  x[3] *= emax;
                  scale *= emax;
                }
                if (scale != 1.0) {
                  i1 = ki + 129;
                  for (int k{129}; k <= i1; k++) {
                    work[k - 1] *= scale;
                  }
                  i1 = ki + 257;
                  for (int k{257}; k <= i1; k++) {
                    work[k - 1] *= scale;
                  }
                }
                work[j + 127] = x[0];
                work[j + 128] = x[1];
                work[j + 255] = x[2];
                work[j + 256] = x[3];
                if ((j - 1 >= 1) && (!(-x[0] == 0.0))) {
                  i1 = j - 2;
                  for (int k{0}; k <= i1; k++) {
                    work[k + 128] += -x[0] * T[i + k];
                  }
                }
                if ((j - 1 >= 1) && (!(-x[1] == 0.0))) {
                  ix = j << 7;
                  i1 = j - 2;
                  for (int k{0}; k <= i1; k++) {
                    work[k + 128] += -x[1] * T[ix + k];
                  }
                }
                blas::xaxpy(j - 1, -x[2], T, i + 1, work);
                blas::xaxpy(j - 1, -x[3], T, (j << 7) + 1, work);
                j -= 2;
              }
            }
            if (guard1) {
              i = j << 7;
              scale = xdlaln2(1, 2, smin, T, (i + j) + 1, work, j + 129, wr_tmp,
                              wi, x, emax);
              if ((emax > 1.0) && (work[j] > 7.7962512091199975E+289 / emax)) {
                x[0] /= emax;
                x[2] /= emax;
                scale /= emax;
              }
              if (scale != 1.0) {
                i1 = ki + 129;
                for (int k{129}; k <= i1; k++) {
                  work[k - 1] *= scale;
                }
                i1 = ki + 257;
                for (int k{257}; k <= i1; k++) {
                  work[k - 1] *= scale;
                }
              }
              work[j + 128] = x[0];
              work[j + 256] = x[2];
              if ((j >= 1) && (!(-x[0] == 0.0))) {
                i1 = j - 1;
                for (int k{0}; k <= i1; k++) {
                  work[k + 128] += -x[0] * T[i + k];
                }
              }
              blas::xaxpy(j, -x[2], T, i + 1, work);
              j--;
            }
          } else {
            exitg1 = 1;
          }
        } while (exitg1 == 0);
        if (ki + 1 > 2) {
          iyend = ix0 + 128;
          emax = work[ki + 127];
          if (emax != 1.0) {
            if (emax == 0.0) {
              if (ix0 + 1 <= iyend) {
                std::memset(&vr[ix0], 0,
                            static_cast<unsigned int>(iyend - ix0) *
                                sizeof(double));
              }
            } else {
              for (j = ix0 + 1; j <= iyend; j++) {
                vr[j - 1] *= emax;
              }
            }
          }
          ix = 128;
          i = ((ki - 2) << 7) + 1;
          for (j = 1; j <= i; j += 128) {
            i1 = j + 127;
            for (int k{j}; k <= i1; k++) {
              iyend = (ix0 + k) - j;
              vr[iyend] += vr[k - 1] * work[ix];
            }
            ix++;
          }
          blas::xgemv(ki - 1, work, work[ki + 256], vr, wr_tmp_tmp + 1);
        } else {
          i = ix0 + 128;
          for (int k{ix0 + 1}; k <= i; k++) {
            vr[k - 1] *= work[128];
          }
          i = wr_tmp_tmp + 128;
          for (int k{wr_tmp_tmp + 1}; k <= i; k++) {
            vr[k - 1] *= work[ki + 256];
          }
        }
        emax = 0.0;
        for (int k{0}; k < 128; k++) {
          emax = std::fmax(emax, std::abs(vr[k + ix0]) +
                                     std::abs(vr[k + wr_tmp_tmp]));
        }
        emax = 1.0 / emax;
        i = ix0 + 128;
        for (int k{ix0 + 1}; k <= i; k++) {
          vr[k - 1] *= emax;
        }
        i = wr_tmp_tmp + 128;
        for (int k{wr_tmp_tmp + 1}; k <= i; k++) {
          vr[k - 1] *= emax;
        }
      }
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xdtrevc3.cpp)
