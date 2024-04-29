//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xztgevc.cpp
//
// Code generation for function 'xztgevc'
//

// Include files
#include "xztgevc.h"
#include "eof_data.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xztgevc(const ::coder::array<creal_T, 2U> &A,
             ::coder::array<creal_T, 2U> &V)
{
  array<creal_T, 1U> work1;
  array<creal_T, 1U> work2;
  array<double, 1U> rworka;
  double BIG;
  double BIGNUM;
  double SMALL;
  double anorm;
  double ascale;
  double d_re;
  double xmx;
  int i;
  int j;
  int loop_ub;
  int n;
  n = A.size(0) - 1;
  work1.set_size(A.size(0));
  loop_ub = A.size(0);
  for (i = 0; i < loop_ub; i++) {
    work1[i].re = 0.0;
    work1[i].im = 0.0;
  }
  work2.set_size(A.size(0));
  loop_ub = A.size(0);
  for (i = 0; i < loop_ub; i++) {
    work2[i].re = 0.0;
    work2[i].im = 0.0;
  }
  SMALL = 2.2250738585072014E-308 * static_cast<double>(A.size(0)) /
          2.2204460492503131E-16;
  BIG = 1.0 / SMALL;
  BIGNUM = 1.0 / (2.2250738585072014E-308 * static_cast<double>(A.size(0)));
  rworka.set_size(A.size(0));
  loop_ub = A.size(0);
  for (i = 0; i < loop_ub; i++) {
    rworka[i] = 0.0;
  }
  anorm = std::abs(A[0].re) + std::abs(A[0].im);
  i = A.size(0);
  for (j = 0; j <= i - 2; j++) {
    for (loop_ub = 0; loop_ub <= j; loop_ub++) {
      rworka[j + 1] =
          rworka[j + 1] + (std::abs(A[loop_ub + A.size(0) * (j + 1)].re) +
                           std::abs(A[loop_ub + A.size(0) * (j + 1)].im));
    }
    d_re = rworka[j + 1] + (std::abs(A[(j + A.size(0) * (j + 1)) + 1].re) +
                            std::abs(A[(j + A.size(0) * (j + 1)) + 1].im));
    if (d_re > anorm) {
      anorm = d_re;
    }
  }
  xmx = anorm;
  if (2.2250738585072014E-308 > anorm) {
    xmx = 2.2250738585072014E-308;
  }
  ascale = 1.0 / xmx;
  i = static_cast<int>(((-1.0 - static_cast<double>(A.size(0))) + 1.0) / -1.0);
  for (int je{0}; je < i; je++) {
    double acoeff;
    double dmin;
    double salpha_im;
    double salpha_re;
    double scale;
    double temp;
    double z;
    int b_je;
    int jr;
    bool lscalea;
    bool lscaleb;
    b_je = n - je;
    xmx = (std::abs(A[b_je + A.size(0) * b_je].re) +
           std::abs(A[b_je + A.size(0) * b_je].im)) *
          ascale;
    if (1.0 > xmx) {
      xmx = 1.0;
    }
    temp = 1.0 / xmx;
    salpha_re = ascale * (temp * A[b_je + A.size(0) * b_je].re);
    salpha_im = ascale * (temp * A[b_je + A.size(0) * b_je].im);
    acoeff = temp * ascale;
    if ((temp >= 2.2250738585072014E-308) && (acoeff < SMALL)) {
      lscalea = true;
    } else {
      lscalea = false;
    }
    z = std::abs(salpha_re) + std::abs(salpha_im);
    if ((z >= 2.2250738585072014E-308) && (z < SMALL)) {
      lscaleb = true;
    } else {
      lscaleb = false;
    }
    scale = 1.0;
    if (lscalea) {
      xmx = anorm;
      if (BIG < anorm) {
        xmx = BIG;
      }
      scale = SMALL / temp * xmx;
    }
    if (lscaleb) {
      d_re = SMALL / z;
      if (d_re > scale) {
        scale = d_re;
      }
    }
    if (lscalea || lscaleb) {
      xmx = acoeff;
      if (1.0 > acoeff) {
        xmx = 1.0;
      }
      if (z > xmx) {
        xmx = z;
      }
      d_re = 1.0 / (2.2250738585072014E-308 * xmx);
      if (d_re < scale) {
        scale = d_re;
      }
      if (lscalea) {
        acoeff = ascale * (scale * temp);
      } else {
        acoeff *= scale;
      }
      salpha_re *= scale;
      salpha_im *= scale;
    }
    for (jr = 0; jr <= n; jr++) {
      work1[jr].re = 0.0;
      work1[jr].im = 0.0;
    }
    work1[b_je].re = 1.0;
    work1[b_je].im = 0.0;
    dmin = 2.2204460492503131E-16 * acoeff * anorm;
    d_re = 2.2204460492503131E-16 * (std::abs(salpha_re) + std::abs(salpha_im));
    if (d_re > dmin) {
      dmin = d_re;
    }
    if (2.2250738585072014E-308 > dmin) {
      dmin = 2.2250738585072014E-308;
    }
    for (jr = 0; jr < b_je; jr++) {
      work1[jr].re = acoeff * A[jr + A.size(0) * b_je].re;
      work1[jr].im = acoeff * A[jr + A.size(0) * b_je].im;
    }
    work1[b_je].re = 1.0;
    work1[b_je].im = 0.0;
    loop_ub = static_cast<int>(
        ((-1.0 - (static_cast<double>(b_je + 1) - 1.0)) + 1.0) / -1.0);
    for (j = 0; j < loop_ub; j++) {
      double ai;
      double b_j;
      double brm;
      double d_im;
      b_j = (static_cast<double>(b_je + 1) - 1.0) + -static_cast<double>(j);
      d_re = acoeff * A[(static_cast<int>(b_j) +
                         A.size(0) * (static_cast<int>(b_j) - 1)) -
                        1]
                          .re -
             salpha_re;
      d_im = acoeff * A[(static_cast<int>(b_j) +
                         A.size(0) * (static_cast<int>(b_j) - 1)) -
                        1]
                          .im -
             salpha_im;
      if (std::abs(d_re) + std::abs(d_im) <= dmin) {
        d_re = dmin;
        d_im = 0.0;
      }
      brm = std::abs(d_re);
      scale = std::abs(d_im);
      xmx = brm + scale;
      if (xmx < 1.0) {
        z = std::abs(work1[static_cast<int>(b_j) - 1].re) +
            std::abs(work1[static_cast<int>(b_j) - 1].im);
        if (z >= BIGNUM * xmx) {
          temp = 1.0 / z;
          for (jr = 0; jr <= b_je; jr++) {
            work1[jr].re = temp * work1[jr].re;
            work1[jr].im = temp * work1[jr].im;
          }
        }
      }
      temp = -work1[static_cast<int>(b_j) - 1].re;
      ai = -work1[static_cast<int>(b_j) - 1].im;
      if (d_im == 0.0) {
        if (ai == 0.0) {
          scale = temp / d_re;
          xmx = 0.0;
        } else if (temp == 0.0) {
          scale = 0.0;
          xmx = ai / d_re;
        } else {
          scale = temp / d_re;
          xmx = ai / d_re;
        }
      } else if (d_re == 0.0) {
        if (temp == 0.0) {
          scale = ai / d_im;
          xmx = 0.0;
        } else if (ai == 0.0) {
          scale = 0.0;
          xmx = -(temp / d_im);
        } else {
          scale = ai / d_im;
          xmx = -(temp / d_im);
        }
      } else if (brm > scale) {
        z = d_im / d_re;
        xmx = d_re + z * d_im;
        scale = (temp + z * ai) / xmx;
        xmx = (ai - z * temp) / xmx;
      } else if (scale == brm) {
        if (d_re > 0.0) {
          z = 0.5;
        } else {
          z = -0.5;
        }
        if (d_im > 0.0) {
          xmx = 0.5;
        } else {
          xmx = -0.5;
        }
        scale = (temp * z + ai * xmx) / brm;
        xmx = (ai * z - temp * xmx) / brm;
      } else {
        z = d_re / d_im;
        xmx = d_im + z * d_re;
        scale = (z * temp + ai) / xmx;
        xmx = (z * ai - temp) / xmx;
      }
      work1[static_cast<int>(b_j) - 1].re = scale;
      work1[static_cast<int>(b_j) - 1].im = xmx;
      if (b_j > 1.0) {
        int i1;
        if (std::abs(work1[static_cast<int>(b_j) - 1].re) +
                std::abs(work1[static_cast<int>(b_j) - 1].im) >
            1.0) {
          temp = 1.0 / (std::abs(work1[static_cast<int>(b_j) - 1].re) +
                        std::abs(work1[static_cast<int>(b_j) - 1].im));
          if (acoeff * rworka[static_cast<int>(b_j) - 1] >= BIGNUM * temp) {
            for (jr = 0; jr <= b_je; jr++) {
              work1[jr].re = temp * work1[jr].re;
              work1[jr].im = temp * work1[jr].im;
            }
          }
        }
        d_re = acoeff * work1[static_cast<int>(b_j) - 1].re;
        d_im = acoeff * work1[static_cast<int>(b_j) - 1].im;
        i1 = static_cast<int>(b_j);
        for (jr = 0; jr <= i1 - 2; jr++) {
          work1[jr].re =
              work1[jr].re +
              (d_re * A[jr + A.size(0) * (static_cast<int>(b_j) - 1)].re -
               d_im * A[jr + A.size(0) * (static_cast<int>(b_j) - 1)].im);
          work1[jr].im =
              work1[jr].im +
              (d_re * A[jr + A.size(0) * (static_cast<int>(b_j) - 1)].im +
               d_im * A[jr + A.size(0) * (static_cast<int>(b_j) - 1)].re);
        }
      }
    }
    for (jr = 0; jr <= n; jr++) {
      work2[jr].re = 0.0;
      work2[jr].im = 0.0;
    }
    for (loop_ub = 0; loop_ub <= b_je; loop_ub++) {
      for (jr = 0; jr <= n; jr++) {
        work2[jr].re =
            work2[jr].re + (V[jr + V.size(0) * loop_ub].re * work1[loop_ub].re -
                            V[jr + V.size(0) * loop_ub].im * work1[loop_ub].im);
        work2[jr].im =
            work2[jr].im + (V[jr + V.size(0) * loop_ub].re * work1[loop_ub].im +
                            V[jr + V.size(0) * loop_ub].im * work1[loop_ub].re);
      }
    }
    xmx = std::abs(work2[0].re) + std::abs(work2[0].im);
    if (n + 1 > 1) {
      for (jr = 0; jr < n; jr++) {
        d_re = std::abs(work2[jr + 1].re) + std::abs(work2[jr + 1].im);
        if (d_re > xmx) {
          xmx = d_re;
        }
      }
    }
    if (xmx > 2.2250738585072014E-308) {
      temp = 1.0 / xmx;
      for (jr = 0; jr <= n; jr++) {
        V[jr + V.size(0) * b_je].re = temp * work2[jr].re;
        V[jr + V.size(0) * b_je].im = temp * work2[jr].im;
      }
    } else {
      for (jr = 0; jr <= n; jr++) {
        V[jr + V.size(0) * b_je].re = 0.0;
        V[jr + V.size(0) * b_je].im = 0.0;
      }
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xztgevc.cpp)
