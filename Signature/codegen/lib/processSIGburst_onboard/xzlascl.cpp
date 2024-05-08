//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzlascl.cpp
//
// Code generation for function 'xzlascl'
//

// Include files
#include "xzlascl.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
namespace reflapack {
void xzlascl(double cfrom, double cto, int m, ::coder::array<double, 1U> &A,
             int iA0)
{
  double cfromc;
  double ctoc;
  bool notdone;
  cfromc = cfrom;
  ctoc = cto;
  notdone = true;
  while (notdone) {
    double cfrom1;
    double cto1;
    double mul;
    cfrom1 = cfromc * 2.0041683600089728E-292;
    cto1 = ctoc / 4.9896007738368E+291;
    if ((std::abs(cfrom1) > std::abs(ctoc)) && (ctoc != 0.0)) {
      mul = 2.0041683600089728E-292;
      cfromc = cfrom1;
    } else if (std::abs(cto1) > std::abs(cfromc)) {
      mul = 4.9896007738368E+291;
      ctoc = cto1;
    } else {
      mul = ctoc / cfromc;
      notdone = false;
    }
    for (int i = 0; i < m; i++) {
      int b_i;
      b_i = (iA0 + i) - 1;
      A[b_i] = A[b_i] * mul;
    }
  }
}

void xzlascl(double cfrom, double cto, int m, int n,
             ::coder::array<double, 2U> &A, int lda)
{
  double cfromc;
  double ctoc;
  bool notdone;
  cfromc = cfrom;
  ctoc = cto;
  notdone = true;
  while (notdone) {
    double cfrom1;
    double cto1;
    double mul;
    cfrom1 = cfromc * 2.0041683600089728E-292;
    cto1 = ctoc / 4.9896007738368E+291;
    if ((std::abs(cfrom1) > std::abs(ctoc)) && (ctoc != 0.0)) {
      mul = 2.0041683600089728E-292;
      cfromc = cfrom1;
    } else if (std::abs(cto1) > std::abs(cfromc)) {
      mul = 4.9896007738368E+291;
      ctoc = cto1;
    } else {
      mul = ctoc / cfromc;
      notdone = false;
    }
    for (int j = 0; j < n; j++) {
      int offset;
      offset = j * lda - 1;
      for (int i = 0; i < m; i++) {
        int b_i;
        b_i = (offset + i) + 1;
        A[b_i] = A[b_i] * mul;
      }
    }
  }
}

} // namespace reflapack
} // namespace internal
} // namespace coder

// End of code generation (xzlascl.cpp)
