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
#include <cstring>

// Function Definitions
namespace coder {
namespace internal {
namespace blas {
void xgemv(int n, const double x[384], double beta1, double y[16384], int iy0)
{
  int iy;
  int iyend;
  iyend = iy0 + 127;
  if (beta1 != 1.0) {
    if (beta1 == 0.0) {
      if (iy0 <= iyend) {
        std::memset(&y[iy0 + -1], 0,
                    static_cast<unsigned int>((iyend - iy0) + 1) *
                        sizeof(double));
      }
    } else {
      for (iy = iy0; iy <= iyend; iy++) {
        y[iy - 1] *= beta1;
      }
    }
  }
  iyend = 256;
  iy = ((n - 1) << 7) + 1;
  for (int iac{1}; iac <= iy; iac += 128) {
    int i;
    i = iac + 127;
    for (int ia{iac}; ia <= i; ia++) {
      int i1;
      i1 = ((iy0 + ia) - iac) - 1;
      y[i1] += y[ia - 1] * x[iyend];
    }
    iyend++;
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (xgemv.cpp)
