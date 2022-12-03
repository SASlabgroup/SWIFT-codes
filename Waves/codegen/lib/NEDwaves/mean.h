//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// mean.h
//
// Code generation for function 'mean'
//

#ifndef MEAN_H
#define MEAN_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void mean(const ::coder::array<double, 2U> &x, ::coder::array<double, 2U> &y);

void mean(const ::coder::array<creal_T, 2U> &x, ::coder::array<creal_T, 2U> &y);

} // namespace coder

#endif
// End of code generation (mean.h)
