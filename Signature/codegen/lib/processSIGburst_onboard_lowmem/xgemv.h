//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xgemv.h
//
// Code generation for function 'xgemv'
//

#ifndef XGEMV_H
#define XGEMV_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace blas {
void xgemv(int m, int n, int lda, const ::coder::array<double, 2U> &x, int ix0,
           double beta1, ::coder::array<double, 2U> &y, int iy0);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xgemv.h)
