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
double mean(const double x[127]);

void mean(const ::coder::array<double, 2U> &x, double y[128]);

void mean(const ::coder::array<double, 3U> &x, double y[16384]);

double mean(const ::coder::array<double, 1U> &x);

} // namespace coder

#endif
// End of code generation (mean.h)
