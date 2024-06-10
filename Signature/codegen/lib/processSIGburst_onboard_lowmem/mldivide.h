//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mldivide.h
//
// Code generation for function 'mldivide'
//

#ifndef MLDIVIDE_H
#define MLDIVIDE_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void b_mldivide(const double A[4], const ::coder::array<double, 2U> &B,
                ::coder::array<double, 2U> &Y);

void mldivide(const double A[9], const ::coder::array<double, 2U> &B,
              ::coder::array<double, 2U> &Y);

} // namespace coder

#endif
// End of code generation (mldivide.h)
