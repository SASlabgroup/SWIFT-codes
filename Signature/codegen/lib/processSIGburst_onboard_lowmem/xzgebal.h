//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzgebal.h
//
// Code generation for function 'xzgebal'
//

#ifndef XZGEBAL_H
#define XZGEBAL_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
int xzgebal(::coder::array<double, 2U> &A, ::coder::array<double, 1U> &scale,
            int *ihi);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzgebal.h)
