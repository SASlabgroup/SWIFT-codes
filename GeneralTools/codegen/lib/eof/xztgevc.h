//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xztgevc.h
//
// Code generation for function 'xztgevc'
//

#ifndef XZTGEVC_H
#define XZTGEVC_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
void xztgevc(const ::coder::array<creal_T, 2U> &A,
             ::coder::array<creal_T, 2U> &V);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xztgevc.h)
