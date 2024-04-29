//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mldivide.cpp
//
// Code generation for function 'mldivide'
//

// Include files
#include "mldivide.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <algorithm>
#include <cmath>

// Function Definitions
namespace coder {
void b_mldivide(const double A[9], const ::coder::array<double, 2U> &B,
                ::coder::array<double, 2U> &Y)
{
  double b_A[9];
  double a21;
  double maxval;
  int r1;
  int r2;
  int r3;
  int rtemp;
  std::copy(&A[0], &A[9], &b_A[0]);
  r1 = 0;
  r2 = 1;
  r3 = 2;
  maxval = std::abs(A[0]);
  a21 = std::abs(A[1]);
  if (a21 > maxval) {
    maxval = a21;
    r1 = 1;
    r2 = 0;
  }
  if (std::abs(A[2]) > maxval) {
    r1 = 2;
    r2 = 1;
    r3 = 0;
  }
  b_A[r2] = A[r2] / A[r1];
  b_A[r3] /= b_A[r1];
  b_A[r2 + 3] -= b_A[r2] * b_A[r1 + 3];
  b_A[r3 + 3] -= b_A[r3] * b_A[r1 + 3];
  b_A[r2 + 6] -= b_A[r2] * b_A[r1 + 6];
  b_A[r3 + 6] -= b_A[r3] * b_A[r1 + 6];
  if (std::abs(b_A[r3 + 3]) > std::abs(b_A[r2 + 3])) {
    rtemp = r2;
    r2 = r3;
    r3 = rtemp;
  }
  b_A[r3 + 3] /= b_A[r2 + 3];
  b_A[r3 + 6] -= b_A[r3 + 3] * b_A[r2 + 6];
  rtemp = B.size(1);
  Y.set_size(3, B.size(1));
  for (int k{0}; k < rtemp; k++) {
    double d;
    maxval = B[r1 + 3 * k];
    a21 = B[r2 + 3 * k] - maxval * b_A[r2];
    d = ((B[r3 + 3 * k] - maxval * b_A[r3]) - a21 * b_A[r3 + 3]) / b_A[r3 + 6];
    Y[3 * k + 2] = d;
    maxval -= d * b_A[r1 + 6];
    a21 -= d * b_A[r2 + 6];
    a21 /= b_A[r2 + 3];
    Y[3 * k + 1] = a21;
    maxval -= a21 * b_A[r1 + 3];
    maxval /= b_A[r1];
    Y[3 * k] = maxval;
  }
}

void mldivide(const double A[4], const ::coder::array<double, 2U> &B,
              ::coder::array<double, 2U> &Y)
{
  if (B.size(1) == 0) {
    Y.set_size(2, 0);
  } else {
    double a21;
    double a22;
    double a22_tmp;
    int nb;
    int r1;
    int r2;
    if (std::abs(A[1]) > std::abs(A[0])) {
      r1 = 1;
      r2 = 0;
    } else {
      r1 = 0;
      r2 = 1;
    }
    a21 = A[r2] / A[r1];
    a22_tmp = A[r1 + 2];
    a22 = A[r2 + 2] - a21 * a22_tmp;
    nb = B.size(1);
    Y.set_size(2, B.size(1));
    for (int k{0}; k < nb; k++) {
      double d;
      d = (B[r2 + 2 * k] - B[r1 + 2 * k] * a21) / a22;
      Y[2 * k + 1] = d;
      Y[2 * k] = (B[r1 + 2 * k] - d * a22_tmp) / A[r1];
    }
  }
}

} // namespace coder

// End of code generation (mldivide.cpp)
