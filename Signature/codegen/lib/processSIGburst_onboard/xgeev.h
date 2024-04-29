//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xgeev.h
//
// Code generation for function 'xgeev'
//

#ifndef XGEEV_H
#define XGEEV_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace lapack {
int xgeev(const ::coder::array<double, 2U> &A, ::coder::array<creal_T, 1U> &W,
          ::coder::array<creal_T, 2U> &VR);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xgeev.h)
