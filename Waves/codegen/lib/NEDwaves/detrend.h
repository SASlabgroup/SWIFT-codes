//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// detrend.h
//
// Code generation for function 'detrend'
//

#ifndef DETREND_H
#define DETREND_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void detrend(::coder::array<float, 1U> &x);

void detrend(const ::coder::array<double, 1U> &x,
             ::coder::array<double, 1U> &y);

} // namespace coder

#endif
// End of code generation (detrend.h)
