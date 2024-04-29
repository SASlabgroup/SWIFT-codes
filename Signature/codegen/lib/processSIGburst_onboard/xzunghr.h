//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzunghr.h
//
// Code generation for function 'xzunghr'
//

#ifndef XZUNGHR_H
#define XZUNGHR_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
void xzunghr(int n, int ilo, int ihi, ::coder::array<double, 2U> &A, int lda,
             const ::coder::array<double, 1U> &tau);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzunghr.h)
