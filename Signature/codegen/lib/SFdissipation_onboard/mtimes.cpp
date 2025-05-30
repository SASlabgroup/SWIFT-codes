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
              const ::coder::array<double, 2U> &B, double C[9])
{
  int inner;
  inner = A.size(0);
  for (int j{0}; j < 3; j++) {
    int boffset;
    int coffset;
    coffset = j * 3;
    boffset = j * B.size(0);
    C[coffset] = 0.0;
    C[coffset + 1] = 0.0;
    C[coffset + 2] = 0.0;
    for (int k{0}; k < inner; k++) {
      double bkj;
      bkj = B[boffset + k];
      C[coffset] += A[k] * bkj;
      C[coffset + 1] += A[A.size(0) + k] * bkj;
      C[coffset + 2] += A[(A.size(0) << 1) + k] * bkj;
    }
  }
}

void mtimes(const ::coder::array<double, 2U> &A, const double B[2],
            ::coder::array<double, 1U> &C)
{
  int m;
  m = A.size(0);
  C.set_size(A.size(0));
  for (int i{0}; i < m; i++) {
    C[i] = A[i] * B[0] + A[A.size(0) + i] * B[1];
  }
}

void mtimes(const ::coder::array<double, 2U> &A,
            const ::coder::array<double, 2U> &B, double C[4])
{
  int inner;
  inner = A.size(0);
  for (int j{0}; j < 2; j++) {
    int boffset;
    int coffset;
    coffset = j << 1;
    boffset = j * B.size(0);
    C[coffset] = 0.0;
    C[coffset + 1] = 0.0;
    for (int k{0}; k < inner; k++) {
      double bkj;
      bkj = B[boffset + k];
      C[coffset] += A[k] * bkj;
      C[coffset + 1] += A[A.size(0) + k] * bkj;
    }
  }
}

} // namespace blas
} // namespace internal
} // namespace coder

// End of code generation (mtimes.cpp)
