//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xgemv.cpp
//
// Code generation for function 'xgemv'
//

// Include files
#include "xgemv.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Definitions
namespace coder {
namespace internal {
namespace blas {
void xgemv(int m, int n, int lda, const ::coder::array<double, 2U> &x, int ix0,
           double beta1, ::coder::array<double, 2U> &y, int iy0)
{
  if (m != 0) {
    int iy;
    int iyend;
    iyend = (iy0 + m) - 1;
    if (beta1 != 1.0) {
      if (beta1 == 0.0) {
        for (iy = iy0; iy <= iyend; iy++) {
          y[iy - 1] = 0.0;
        }
      } else {
        for (iy = iy0; iy <= iyend; iy++) {
          y[iy - 1] = beta1 * y[iy - 1];
        }
      }
    }
    iyend = ix0;
    iy = lda * (n - 1) + 1;
    for (int iac{1}; lda < 0 ? iac >= iy : iac <= iy; iac += lda) {
      int i;
      i = (iac + m) - 1;
      for (int ia{iac}; ia <= i; ia++) {
        int i1;
        i1 = ((iy0 + ia) - iac) - 1;
        y[i1] = y[i1] + y[ia - 1] * x[iyend - 1];
      }
      iyend++;
    }
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (xgemv.cpp)
