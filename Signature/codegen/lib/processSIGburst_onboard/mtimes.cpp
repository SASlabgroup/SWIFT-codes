//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mtimes.cpp
//
// Code generation for function 'mtimes'
//

// Include files
#include "mtimes.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
namespace blas {
void b_mtimes(const ::coder::array<double, 2U> &A,
              const ::coder::array<double, 2U> &B, double C[4])
{
  int inner;
  inner = A.size(0);
  for (int j = 0; j < 2; j++) {
    int boffset;
    int coffset;
    coffset = j << 1;
    boffset = j * B.size(0);
    C[coffset] = 0.0;
    C[coffset + 1] = 0.0;
    for (int k = 0; k < inner; k++) {
      double bkj;
      bkj = B[boffset + k];
      C[coffset] += A[k] * bkj;
      C[coffset + 1] += A[A.size(0) + k] * bkj;
    }
  }
}

void mtimes(const ::coder::array<double, 2U> &A,
            const ::coder::array<double, 2U> &B, ::coder::array<double, 2U> &C)
{
  int inner;
  int mc;
  int nc;
  mc = A.size(1);
  inner = A.size(0);
  nc = B.size(1);
  C.set_size(A.size(1), B.size(1));
  for (int j = 0; j < nc; j++) {
    int boffset;
    int coffset;
    coffset = j * mc;
    boffset = j * B.size(0);
    for (int i = 0; i < mc; i++) {
      C[coffset + i] = 0.0;
    }
    for (int k = 0; k < inner; k++) {
      double bkj;
      bkj = B[boffset + k];
      for (int i = 0; i < mc; i++) {
        int b_i;
        b_i = coffset + i;
        C[b_i] = C[b_i] + A[i * A.size(0) + k] * bkj;
      }
    }
  }
}

void mtimes(const ::coder::array<creal_T, 2U> &A,
            const ::coder::array<creal_T, 2U> &B,
            ::coder::array<creal_T, 2U> &C)
{
  int inner;
  int m;
  int n;
  m = A.size(0);
  inner = A.size(1);
  n = B.size(0);
  C.set_size(A.size(0), B.size(0));
  for (int j = 0; j < n; j++) {
    int coffset;
    coffset = j * m;
    for (int i = 0; i < m; i++) {
      double s_im;
      double s_re;
      int k;
      s_re = 0.0;
      s_im = 0.0;
      for (k = 0; k < inner; k++) {
        double A_re_tmp;
        double B_im;
        double B_re;
        double b_A_re_tmp;
        B_re = B[k * B.size(0) + j].re;
        B_im = -B[k * B.size(0) + j].im;
        A_re_tmp = A[k * A.size(0) + i].re;
        b_A_re_tmp = A[k * A.size(0) + i].im;
        s_re += A_re_tmp * B_re - b_A_re_tmp * B_im;
        s_im += A_re_tmp * B_im + b_A_re_tmp * B_re;
      }
      k = coffset + i;
      C[k].re = s_re;
      C[k].im = s_im;
    }
  }
}

void mtimes(const ::coder::array<double, 2U> &A,
            const ::coder::array<double, 2U> &B, double C[9])
{
  int inner;
  inner = A.size(0);
  for (int j = 0; j < 3; j++) {
    int boffset;
    int coffset;
    coffset = j * 3;
    boffset = j * B.size(0);
    C[coffset] = 0.0;
    C[coffset + 1] = 0.0;
    C[coffset + 2] = 0.0;
    for (int k = 0; k < inner; k++) {
      double bkj;
      bkj = B[boffset + k];
      C[coffset] += A[k] * bkj;
      C[coffset + 1] += A[A.size(0) + k] * bkj;
      C[coffset + 2] += A[(A.size(0) << 1) + k] * bkj;
    }
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (mtimes.cpp)
