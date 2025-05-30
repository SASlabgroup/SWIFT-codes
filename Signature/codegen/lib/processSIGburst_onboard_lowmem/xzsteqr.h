//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzsteqr.h
//
// Code generation for function 'xzsteqr'
//

#ifndef XZSTEQR_H
#define XZSTEQR_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
int xzsteqr(::coder::array<double, 1U> &d, ::coder::array<double, 1U> &e,
            ::coder::array<double, 2U> &z);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzsteqr.h)
