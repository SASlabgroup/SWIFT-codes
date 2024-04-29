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
#include <cstring>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xzunghr(int ilo, int ihi, double A[16384], const double tau[127])
{
  double work[128];
  int a;
  int i;
  int ia;
  int ia0;
  int itau;
  int nh;
  nh = ihi - ilo;
  a = ilo + 1;
  for (int j{ihi}; j >= a; j--) {
    ia = (j - 1) << 7;
    i = static_cast<unsigned char>(j - 1);
    std::memset(&A[ia], 0,
                static_cast<unsigned int>((i + ia) - ia) * sizeof(double));
    i = j + 1;
    for (int b_i{i}; b_i <= ihi; b_i++) {
      itau = ia + b_i;
      A[itau - 1] = A[itau - 129];
    }
    i = ihi + 1;
    if (i <= 128) {
      std::memset(&A[(i + ia) + -1], 0,
                  static_cast<unsigned int>(((ia - i) - ia) + 129) *
                      sizeof(double));
    }
  }
  i = static_cast<unsigned char>(ilo);
  for (int j{0}; j < i; j++) {
    ia = j << 7;
    std::memset(&A[ia], 0, 128U * sizeof(double));
    A[ia + j] = 1.0;
  }
  i = ihi + 1;
  for (int j{i}; j < 129; j++) {
    ia = (j - 1) << 7;
    std::memset(&A[ia], 0, 128U * sizeof(double));
    A[(ia + j) - 1] = 1.0;
  }
  ia0 = ilo + (ilo << 7);
  if (nh >= 1) {
    i = nh - 1;
    for (int j{nh}; j <= i; j++) {
      ia = ia0 + (j << 7);
      std::memset(&A[ia], 0,
                  static_cast<unsigned int>(((i + ia) - ia) + 1) *
                      sizeof(double));
      A[ia + j] = 1.0;
    }
    itau = (ilo + nh) - 2;
    std::memset(&work[0], 0, 128U * sizeof(double));
    for (int b_i{nh}; b_i >= 1; b_i--) {
      ia = (ia0 + b_i) + ((b_i - 1) << 7);
      if (b_i < nh) {
        A[ia - 1] = 1.0;
        i = nh - b_i;
        xzlarf(i + 1, i, ia, tau[itau], A, ia + 128, work);
        a = ia + 1;
        i = (ia + nh) - b_i;
        for (int j{a}; j <= i; j++) {
          A[j - 1] *= -tau[itau];
        }
      }
      A[ia - 1] = 1.0 - tau[itau];
      i = static_cast<unsigned char>(b_i - 1);
      for (int j{0}; j < i; j++) {
        A[(ia - j) - 2] = 0.0;
      }
      itau--;
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzunghr.cpp)
