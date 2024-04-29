//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzungqr.cpp
//
// Code generation for function 'xzungqr'
//

// Include files
#include "xzungqr.h"
#include "rt_nonfinite.h"
#include "xzlarf.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xzungqr(int m, int n, int k, ::coder::array<double, 2U> &A, int ia0,
             int lda, const ::coder::array<double, 1U> &tau)
{
  array<double, 1U> work;
  if (n >= 1) {
    int i;
    int ia;
    int iaii;
    int itau;
    i = n - 1;
    for (int j{k}; j <= i; j++) {
      ia = (ia0 + j * lda) - 1;
      iaii = m - 1;
      for (int b_i{0}; b_i <= iaii; b_i++) {
        A[ia + b_i] = 0.0;
      }
      A[ia + j] = 1.0;
    }
    unsigned int unnamed_idx_0;
    itau = k - 1;
    unnamed_idx_0 = static_cast<unsigned int>(A.size(1));
    work.set_size(static_cast<int>(unnamed_idx_0));
    ia = static_cast<int>(unnamed_idx_0);
    for (i = 0; i < ia; i++) {
      work[i] = 0.0;
    }
    for (int b_i{k}; b_i >= 1; b_i--) {
      iaii = ((ia0 + b_i) + (b_i - 1) * lda) - 1;
      if (b_i < n) {
        A[iaii - 1] = 1.0;
        xzlarf((m - b_i) + 1, n - b_i, iaii, tau[itau], A, iaii + lda, lda,
               work);
      }
      if (b_i < m) {
        ia = iaii + 1;
        i = (iaii + m) - b_i;
        for (int j{ia}; j <= i; j++) {
          A[j - 1] = -tau[itau] * A[j - 1];
        }
      }
      A[iaii - 1] = 1.0 - tau[itau];
      for (int j{0}; j <= b_i - 2; j++) {
        A[(iaii - j) - 2] = 0.0;
      }
      itau--;
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzungqr.cpp)
