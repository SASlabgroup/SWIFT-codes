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
void mtimes(const ::coder::array<creal_T, 2U> &A,
            const ::coder::array<creal_T, 2U> &B,
            ::coder::array<creal_T, 2U> &C)
{
  int inner;
  int n;
  inner = A.size(1);
  n = B.size(0);
  C.set_size(128, B.size(0));
  for (int j{0}; j < n; j++) {
    int coffset;
    coffset = j << 7;
    for (int i{0}; i < 128; i++) {
      double s_im;
      double s_re;
      int A_re_tmp_tmp;
      s_re = 0.0;
      s_im = 0.0;
      for (int k{0}; k < inner; k++) {
        double A_re_tmp;
        double B_im;
        double B_re;
        double b_A_re_tmp;
        B_re = B[k * B.size(0) + j].re;
        B_im = -B[k * B.size(0) + j].im;
        A_re_tmp_tmp = (k << 7) + i;
        A_re_tmp = A[A_re_tmp_tmp].re;
        b_A_re_tmp = A[A_re_tmp_tmp].im;
        s_re += A_re_tmp * B_re - b_A_re_tmp * B_im;
        s_im += A_re_tmp * B_im + b_A_re_tmp * B_re;
      }
      A_re_tmp_tmp = coffset + i;
      C[A_re_tmp_tmp].re = s_re;
      C[A_re_tmp_tmp].im = s_im;
    }
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (mtimes.cpp)
