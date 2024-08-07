//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzggbal.h
//
// Code generation for function 'xzggbal'
//

#ifndef XZGGBAL_H
#define XZGGBAL_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
void xzggbal(::coder::array<creal_T, 2U> &A, int *ilo, int *ihi,
             ::coder::array<int, 1U> &rscale);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzggbal.h)
