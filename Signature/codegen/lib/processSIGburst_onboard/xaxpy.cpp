//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xaxpy.cpp
//
// Code generation for function 'xaxpy'
//

// Include files
#include "xaxpy.h"
#include "rt_nonfinite.h"

// Function Definitions
namespace coder {
namespace internal {
namespace blas {
void xaxpy(int n, double a, const double x[16384], int ix0, double y[384])
{
  if ((n >= 1) && (!(a == 0.0))) {
    int i;
    i = n - 1;
    for (int k{0}; k <= i; k++) {
      y[k + 256] += a * x[(ix0 + k) - 1];
    }
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (xaxpy.cpp)
