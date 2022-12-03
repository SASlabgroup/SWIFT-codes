//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// qrsolve.h
//
// Code generation for function 'qrsolve'
//

#ifndef QRSOLVE_H
#define QRSOLVE_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
void qrsolve(const ::coder::array<float, 2U> &A,
             const ::coder::array<float, 1U> &B, float Y[2], int *rankA);

}
} // namespace coder

#endif
// End of code generation (qrsolve.h)
