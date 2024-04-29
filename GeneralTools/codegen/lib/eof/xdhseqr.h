//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xdhseqr.h
//
// Code generation for function 'xdhseqr'
//

#ifndef XDHSEQR_H
#define XDHSEQR_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
int eml_dlahqr(::coder::array<double, 2U> &h, ::coder::array<double, 2U> &z);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xdhseqr.h)
