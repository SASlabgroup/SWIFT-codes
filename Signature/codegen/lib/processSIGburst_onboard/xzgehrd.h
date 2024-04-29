//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xzgehrd.h
//
// Code generation for function 'xzgehrd'
//

#ifndef XZGEHRD_H
#define XZGEHRD_H

// Include files
#include "rtwtypes.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
namespace reflapack {
void xzgehrd(double a[16384], int ilo, int ihi, double tau[127]);

}
} // namespace internal
} // namespace coder

#endif
// End of code generation (xzgehrd.h)
