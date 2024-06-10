//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sort.h
//
// Code generation for function 'sort'
//

#ifndef SORT_H
#define SORT_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
namespace internal {
void sort(::coder::array<creal_T, 1U> &x, ::coder::array<int, 1U> &idx);

void sort(::coder::array<double, 1U> &x, ::coder::array<int, 1U> &idx);

} // namespace internal
} // namespace coder

#endif
// End of code generation (sort.h)
