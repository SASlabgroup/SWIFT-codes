//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzlascl.h
//
// Code generation for function 'xzlascl'
//

#ifndef XZLASCL_H
#define XZLASCL_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
void xzlascl(double cfrom, double cto, int m, ::coder::array<double, 1U> &A,
             int iA0);

void xzlascl(double cfrom, double cto, int m, int n,
             ::coder::array<double, 2U> &A, int lda);

} // namespace reflapack
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzlascl.h)
