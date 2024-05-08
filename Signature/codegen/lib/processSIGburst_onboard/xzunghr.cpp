//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzunghr.cpp
//
// Code generation for function 'xzunghr'
//

// Include files
#include "xzunghr.h"
#include "rt_nonfinite.h"
#include "xzlarf.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xzunghr(int n, int ilo, int ihi, ::coder::array<double, 2U> &A, int lda,
             const ::coder::array<double, 1U> &tau)
{
  array<double, 1U> work;
  int a;
  int b_i;
  int ia;
  int ia0;
  int iajm1;
  int nh;
  nh = ihi - ilo;
  a = ilo + 1;
  for (int j = ihi; j >= a; j--) {
    ia = (j - 1) * lda - 1;
    for (int i = 0; i <= j - 2; i++) {
      A[(ia + i) + 1] = 0.0;
    }
    iajm1 = ia - lda;
    b_i = j + 1;
    for (int i = b_i; i <= ihi; i++) {
      A[ia + i] = A[iajm1 + i];
    }
    b_i = ihi + 1;
    for (int i = b_i; i <= n; i++) {
      A[ia + i] = 0.0;
    }
  }
  for (int j = 0; j < ilo; j++) {
    ia = j * lda;
    for (int i = 0; i < n; i++) {
      A[ia + i] = 0.0;
    }
    A[ia + j] = 1.0;
  }
  b_i = ihi + 1;
  for (int j = b_i; j <= n; j++) {
    ia = (j - 1) * lda;
    for (int i = 0; i < n; i++) {
      A[ia + i] = 0.0;
    }
    A[(ia + j) - 1] = 1.0;
  }
  ia0 = ilo + ilo * lda;
  if (nh >= 1) {
    b_i = nh - 1;
    for (int j = nh; j <= b_i; j++) {
      ia = ia0 + j * lda;
      for (int i = 0; i <= b_i; i++) {
        A[ia + i] = 0.0;
      }
      A[ia + j] = 1.0;
    }
    unsigned int unnamed_idx_0;
    ia = (ilo + nh) - 2;
    unnamed_idx_0 = static_cast<unsigned int>(A.size(1));
    work.set_size(static_cast<int>(unnamed_idx_0));
    a = static_cast<int>(unnamed_idx_0);
    for (b_i = 0; b_i < a; b_i++) {
      work[b_i] = 0.0;
    }
    for (int i = nh; i >= 1; i--) {
      iajm1 = (ia0 + i) + (i - 1) * lda;
      if (i < nh) {
        A[iajm1 - 1] = 1.0;
        b_i = nh - i;
        xzlarf(b_i + 1, b_i, iajm1, tau[ia], A, iajm1 + lda, lda, work);
        a = iajm1 + 1;
        b_i = (iajm1 + nh) - i;
        for (int j = a; j <= b_i; j++) {
          A[j - 1] = -tau[ia] * A[j - 1];
        }
      }
      A[iajm1 - 1] = 1.0 - tau[ia];
      for (int j = 0; j <= i - 2; j++) {
        A[(iajm1 - j) - 2] = 0.0;
      }
      ia--;
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzunghr.cpp)
